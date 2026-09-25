import 'dart:typed_data';
import '../models/line_data.dart';

abstract class FingerprintRepository {
  Future<Uint8List> scanFingerprint();
  Future<Uint8List> scanFingerprintDevice();
  Future<Uint8List> processImage(String path, Uint8List fallbackBytes);
  Future<int> countRidges({
    required String path,
    required double startX,
    required double startY,
    required double endX,
    required double endY,
  });

  Future<bool> startLiveScan({
    required bool isFrame,
    required bool isLfd,
    required bool isInvert,
    required bool isNfiq,
    required bool isUsbHost,
  });
  Future<Uint8List?> stopLiveScan();
  Stream<Map<dynamic, dynamic>> get liveScanStream;
  Future<void> syncAnalysisData(List<LineData> lines);
}
