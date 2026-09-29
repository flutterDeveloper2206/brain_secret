import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/errors/error_handler.dart';
import '../../../core/widgets/glass_snackbar.dart';
import '../../../data/models/customer_fingerprint.dart';
import '../../../data/models/line_data.dart';
import '../../../data/repositories/fingerprint_repo.dart';

class AnalysisController extends GetxController {
  final FingerprintRepository repository;

  AnalysisController({required this.repository});

  // Reactive variables
  final Rxn<ui.Image> originalImage = Rxn<ui.Image>();
  final Rxn<ui.Image> processedImage = Rxn<ui.Image>();
  final RxBool showProcessed = true.obs;
  final RxBool isProcessingImage = false.obs;
  final RxBool isUpdating = false.obs;

  final Rxn<Offset> corePoint = Rxn<Offset>();
  final RxList<LineData> lines = <LineData>[].obs;
  final Rxn<LineData> currentLine = Rxn<LineData>();

  /// Set when opened from Analyze Fingerprints Edit.
  final Rxn<CustomerFingerprint> editingFingerprint = Rxn<CustomerFingerprint>();

  late final TextEditingController typeController;
  late final TextEditingController valueController;

  String? imagePath;
  Size? canvasSize;
  Size? imageOriginalSize;
  Rect? imageDestRect;

  bool get isFingerprintEditMode => editingFingerprint.value != null;

  @override
  void onInit() {
    typeController = TextEditingController();
    valueController = TextEditingController();
    super.onInit();
    _loadImageContext();
  }

  @override
  void onClose() {
    typeController.dispose();
    valueController.dispose();
    super.onClose();
  }

  Future<void> _loadImageContext() async {
    isProcessingImage.value = true;
    try {
      final args = Get.arguments as Map<String, dynamic>?;
      if (args == null) {
        Get.back();
        GlassSnackbar.error('No image context provided for analysis.');
        return;
      }

      Uint8List? bytes;

      if (args.containsKey('fingerprint')) {
        final item = args['fingerprint'] as CustomerFingerprint;
        editingFingerprint.value = item;
        typeController.text = item.fingerType ?? '';
        valueController.text =
            item.fingerValue == 0 ? '' : item.fingerValue.toString();

        if (item.fingerImageUrl.isEmpty) {
          Get.back();
          GlassSnackbar.error('Fingerprint image URL is missing.');
          return;
        }
        bytes = await _downloadImageBytes(item.fingerImageUrl);
      } else if (args.containsKey('bytes')) {
        bytes = args['bytes'] as Uint8List;
      }

      if (bytes == null || bytes.isEmpty) {
        Get.back();
        GlassSnackbar.error('No image context provided for analysis.');
        return;
      }

      await _applyImageBytes(bytes);
    } catch (e) {
      ErrorHandler.handleError(e);
    } finally {
      isProcessingImage.value = false;
    }
  }

  Future<Uint8List> _downloadImageBytes(String url) async {
    final uri = Uri.parse(url);
    final request = await HttpClient().getUrl(uri);
    final response = await request.close();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpException(
        'Failed to download fingerprint image (${response.statusCode})',
        uri: uri,
      );
    }
    return consolidateHttpClientResponseBytes(response);
  }

  Future<void> _applyImageBytes(Uint8List bytes) async {
    final ui.Image original = await decodeImageFromList(bytes);
    originalImage.value = original;
    imageOriginalSize = Size(
      original.width.toDouble(),
      original.height.toDouble(),
    );

    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/temp_fingerprint.png');
    await file.writeAsBytes(bytes);
    imagePath = file.path;

    final Uint8List processedBytes = await repository.processImage(
      imagePath!,
      bytes,
    );
    processedImage.value = await decodeImageFromList(processedBytes);
    showProcessed.value = true;
  }

  void toggleView() {
    showProcessed.toggle();
  }

  void resetCore() {
    corePoint.value = null;
    lines.clear();
  }

  void clearLines() {
    lines.clear();
  }

  void setCorePoint(Offset localPosition) {
    if (corePoint.value == null) {
      corePoint.value = localPosition;
    }
  }

  void startCurrentLine(Offset startOffset) {
    if (corePoint.value != null) {
      currentLine.value = LineData(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        start: corePoint.value!,
        end: startOffset,
        color: getNextColor(),
      );
    }
  }

  void updateCurrentLine(Offset localPosition) {
    if (currentLine.value != null) {
      currentLine.value!.end = localPosition;
      currentLine.refresh();
    }
  }

  void finishCurrentLine(Offset localPosition) {
    if (currentLine.value != null) {
      final finishedLine = currentLine.value!;
      finishedLine.end = localPosition;
      lines.add(finishedLine);
      currentLine.value = null;
      _calculateRidgeCount(finishedLine);
    }
  }

  Future<void> _calculateRidgeCount(LineData line) async {
    if (imagePath == null ||
        processedImage.value == null ||
        imageDestRect == null ||
        imageOriginalSize == null) {
      return;
    }

    final scaleX = imageOriginalSize!.width / imageDestRect!.width;
    final scaleY = imageOriginalSize!.height / imageDestRect!.height;

    final imgStartX = (line.start.dx - imageDestRect!.left) * scaleX;
    final imgStartY = (line.start.dy - imageDestRect!.top) * scaleY;
    final imgEndX = (line.end.dx - imageDestRect!.left) * scaleX;
    final imgEndY = (line.end.dy - imageDestRect!.top) * scaleY;

    try {
      final int count = await repository.countRidges(
        path: imagePath!,
        startX: imgStartX,
        startY: imgStartY,
        endX: imgEndX,
        endY: imgEndY,
      );

      line.ridgeCount = count;
      lines.refresh();

      if (isFingerprintEditMode) {
        valueController.text = count.toString();
      }
    } catch (e) {
      ErrorHandler.handleError(e);
    }
  }

  Future<void> saveAnalysis() async {
    final item = editingFingerprint.value;
    if (item == null || isUpdating.value) return;

    final type = typeController.text.trim();
    final value = int.tryParse(valueController.text.trim());

    if (type.isEmpty) {
      GlassSnackbar.warning(
        'Please enter a finger type',
        title: 'Missing type',
      );
      return;
    }
    if (value == null) {
      GlassSnackbar.warning(
        'Please enter a numeric value',
        title: 'Missing value',
      );
      return;
    }

    isUpdating.value = true;
    try {
      final ok = await repository.updateCustomerFingerprint(
        fingerprintId: item.fingerprintId,
        fingerType: type,
        fingerValue: value,
      );
      if (!ok) {
        GlassSnackbar.error('Unable to update fingerprint.');
        return;
      }
      // Pop route before snackbar so Get.back doesn't dismiss the snackbar.
      if (Get.isSnackbarOpen) {
        Get.closeCurrentSnackbar();
      }
      Get.back(result: true);
      GlassSnackbar.success('Analysis saved', title: 'Updated');
    } catch (e) {
      ErrorHandler.handleError(e);
    } finally {
      if (!isClosed) isUpdating.value = false;
    }
  }

  Future<void> syncAnalysisData() async {
    if (lines.isEmpty) {
      Get.snackbar(
        'Sync Data',
        'No lines generated to sync yet.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      await repository.syncAnalysisData(lines);
      Get.snackbar(
        'Success',
        'Analysis results successfully synced to remote database.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
    } catch (e) {
      ErrorHandler.handleError(e);
    }
  }

  Color getNextColor() {
    final colors = [
      Colors.redAccent,
      Colors.greenAccent,
      Colors.orangeAccent,
      Colors.purpleAccent,
      Colors.yellowAccent,
      Colors.cyanAccent,
      Colors.pinkAccent,
      Colors.limeAccent,
    ];
    return colors[lines.length % colors.length];
  }
}
