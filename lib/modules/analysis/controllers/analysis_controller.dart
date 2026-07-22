import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import '../../../core/errors/error_handler.dart';
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

  final Rxn<Offset> corePoint = Rxn<Offset>();
  final RxList<LineData> lines = <LineData>[].obs;
  final Rxn<LineData> currentLine = Rxn<LineData>();

  String? imagePath;
  Size? canvasSize;
  Size? imageOriginalSize;
  Rect? imageDestRect;

  @override
  void onInit() {
    super.onInit();
    _loadImageContext();
  }

  Future<void> _loadImageContext() async {
    isProcessingImage.value = true;
    try {
      final args = Get.arguments as Map<String, dynamic>?;
      if (args != null && args.containsKey('bytes')) {
        final Uint8List bytes = args['bytes'] as Uint8List;

        // Decode original image
        final ui.Image original = await decodeImageFromList(bytes);
        originalImage.value = original;
        imageOriginalSize = Size(
          original.width.toDouble(),
          original.height.toDouble(),
        );

        // Write bytes to a temp file to get a path for native OpenCV loading
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/temp_fingerprint.png');
        await file.writeAsBytes(bytes);
        imagePath = file.path;

        // Process through repository binarizer
        final Uint8List processedBytes = await repository.processImage(
          imagePath!,
          bytes,
        );
        processedImage.value = await decodeImageFromList(processedBytes);
        showProcessed.value = true;
      } else {
        Get.back();
        Get.snackbar("Error", "No image context provided for analysis.");
      }
    } catch (e) {
      ErrorHandler.handleError(e);
    } finally {
      isProcessingImage.value = false;
    }
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

    double scaleX = imageOriginalSize!.width / imageDestRect!.width;
    double scaleY = imageOriginalSize!.height / imageDestRect!.height;

    double imgStartX = (line.start.dx - imageDestRect!.left) * scaleX;
    double imgStartY = (line.start.dy - imageDestRect!.top) * scaleY;
    double imgEndX = (line.end.dx - imageDestRect!.left) * scaleX;
    double imgEndY = (line.end.dy - imageDestRect!.top) * scaleY;

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
    } catch (e) {
      ErrorHandler.handleError(e);
    }
  }

  Future<void> syncAnalysisData() async {
    if (lines.isEmpty) {
      Get.snackbar(
        "Sync Data",
        "No lines generated to sync yet.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      await repository.syncAnalysisData(lines);
      Get.snackbar(
        "Success",
        "Analysis results successfully synced to remote database.",
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
