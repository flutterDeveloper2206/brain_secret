import 'dart:typed_data';
import '../models/customer_fingerprint.dart';
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

  /// Uploads three fingerprint images (L2R / L2L / L2C) for a customer.
  /// [fingerName] is the selected finger code (L1–L5 left, R1–R5 right).
  Future<void> addCustomerFingerprint({
    required Uint8List l2r,
    required Uint8List l2l,
    required Uint8List l2c,
    required String fingerName,
  });

  Future<List<CustomerFingerprint>> getCustomerFingerprints({
    int customerId = 13,
  });

  Future<void> updateCustomerFingerprint({
    required int fingerprintId,
    required String fingerType,
    required int fingerValue,
  });
}
