import 'dart:typed_data';
import '../../core/errors/exceptions.dart';
import '../models/line_data.dart';
import '../providers/api_service.dart';
import '../providers/native_service.dart';
import 'fingerprint_repo.dart';

class FingerprintRepositoryImpl implements FingerprintRepository {
  final NativeService nativeService;
  final ApiService apiService;

  FingerprintRepositoryImpl({
    required this.nativeService,
    required this.apiService,
  });

  @override
  Future<Uint8List> scanFingerprint() async {
    try {
      return await nativeService.scanFingerprint();
    } catch (e) {
      if (e is AppException) rethrow;
      throw PlatformProcessingException("Failed to scan fingerprint from USB device: $e");
    }
  }

  @override
  Future<Uint8List> scanFingerprintDevice() async {
    try {
      return await nativeService.scanFingerprintDevice();
    } catch (e) {
      if (e is AppException) rethrow;
      throw PlatformProcessingException("Failed to scan fingerprint from physical USB device: $e");
    }
  }

  @override
  Future<Uint8List> processImage(String path, Uint8List fallbackBytes) async {
    try {
      return await nativeService.processImage(path, fallbackBytes);
    } catch (e) {
      if (e is AppException) rethrow;
      throw PlatformProcessingException("Failed to run image enhancement algorithm: $e");
    }
  }

  @override
  Future<int> countRidges({
    required String path,
    required double startX,
    required double startY,
    required double endX,
    required double endY,
  }) async {
    try {
      return await nativeService.countRidges(
        path: path,
        startX: startX,
        startY: startY,
        endX: endX,
        endY: endY,
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw PlatformProcessingException("Method channel calculation failure: $e");
    }
  }

  @override
  Future<bool> startLiveScan({
    required bool isFrame,
    required bool isLfd,
    required bool isInvert,
    required bool isNfiq,
    required bool isUsbHost,
  }) async {
    try {
      return await nativeService.startLiveScan(
        isFrame: isFrame,
        isLfd: isLfd,
        isInvert: isInvert,
        isNfiq: isNfiq,
        isUsbHost: isUsbHost,
      );
    } catch (e) {
      throw PlatformProcessingException("Failed to start live scanning: $e");
    }
  }

  @override
  Future<Uint8List?> stopLiveScan() async {
    try {
      return await nativeService.stopLiveScan();
    } catch (e) {
      throw PlatformProcessingException("Failed to stop live scanning: $e");
    }
  }

  @override
  Stream<Map<dynamic, dynamic>> get liveScanStream => nativeService.liveScanStream;

  @override
  Future<void> syncAnalysisData(List<LineData> lines) async {
    try {
      final body = {
        'lines_count': lines.length,
        'timestamp': DateTime.now().toIso8601String(),
        'lines': lines.map((l) => {
          'id': l.id,
          'start_x': l.start.dx,
          'start_y': l.start.dy,
          'end_x': l.end.dx,
          'end_y': l.end.dy,
          'ridge_count': l.ridgeCount,
        }).toList(),
      };
      await apiService.safePost('/sync', body);
    } on NetworkException {
      rethrow;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw AppException("An unexpected error occurred during database sync: $e");
    }
  }
}
