import 'dart:convert';
import 'dart:typed_data';
import 'package:get/get.dart';
import '../../core/errors/exceptions.dart';
import '../../core/values/app_constants.dart';
import '../models/customer_fingerprint.dart';
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

  void _ensureToken() {
    final token = apiService.authToken;
    if (token == null || token.isEmpty) {
      throw ServerException('Authentication token is missing.');
    }
  }

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

  @override
  Future<void> addCustomerFingerprint({
    required Uint8List l2r,
    required Uint8List l2l,
    required Uint8List l2c,
    required String fingerName,
  }) async {
    try {
      _ensureToken();

      // customer_id / parent_id static for now; finger_name from hand selector.
      final payload = {
        'customer_id': AppConstants.defaultFingerprintCustomerId,
        'parent_id': 12,
        'finger_name': fingerName,
      };

      final formData = FormData({
        'data': jsonEncode(payload),
        'L2R': MultipartFile(l2r, filename: 'L2R.jpg'),
        'L2L': MultipartFile(l2l, filename: 'L2L.jpg'),
        'L2C': MultipartFile(l2c, filename: 'L2C.jpg'),
      });

      final response = await apiService.safeMultipartPost(
        AppConstants.addCustomerFingerprintEndpoint,
        formData,
      );

      final body = response.body;
      if (body is Map) {
        final status = body['statusCode'] ?? body['status_code'];
        final code = status is int
            ? status
            : int.tryParse(status?.toString() ?? '') ?? 0;
        if (code != 0 && code != 200 && code != 201) {
          final message = body['message']?.toString().trim();
          throw ServerException(
            (message == null || message.isEmpty)
                ? 'Unable to upload fingerprint.'
                : message,
            statusCode: code,
          );
        }
      }
    } on AppException {
      rethrow;
    } catch (e) {
      throw ServerException('Unable to upload fingerprint. Please try again.');
    }
  }

  void _ensureEnvelopeSuccess(dynamic body, String fallbackMessage) {
    if (body is! Map) return;
    final status = body['statusCode'] ?? body['status_code'];
    final code = status is int
        ? status
        : int.tryParse(status?.toString() ?? '') ?? 0;
    if (code != 0 && code != 200 && code != 201) {
      final message = body['message']?.toString().trim();
      throw ServerException(
        (message == null || message.isEmpty) ? fallbackMessage : message,
        statusCode: code,
      );
    }
  }

  @override
  Future<List<CustomerFingerprint>> getCustomerFingerprints({
    int customerId = AppConstants.defaultFingerprintCustomerId,
  }) async {
    try {
      _ensureToken();
      final response = await apiService.safeGet(
        AppConstants.getCustomerFingerprintsEndpoint(customerId),
      );

      final body = response.body;
      if (body is! Map) {
        throw ServerException('Unexpected fingerprints response.');
      }

      _ensureEnvelopeSuccess(body, 'Unable to load fingerprints.');

      final raw = body['data'];
      if (raw is! List) return const [];

      return raw
          .whereType<Map>()
          .map(
            (item) => CustomerFingerprint.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();
    } on AppException {
      rethrow;
    } catch (e) {
      throw ServerException('Unable to load fingerprints. Please try again.');
    }
  }

  @override
  Future<void> updateCustomerFingerprint({
    required int fingerprintId,
    required String fingerType,
    required int fingerValue,
  }) async {
    try {
      _ensureToken();
      final response = await apiService.safePost(
        AppConstants.updateCustomerFingerprintEndpoint,
        {
          'fingerprint_id': fingerprintId,
          'finger_type': fingerType,
          'finger_value': fingerValue,
        },
      );

      _ensureEnvelopeSuccess(
        response.body,
        'Unable to update fingerprint.',
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw ServerException('Unable to update fingerprint. Please try again.');
    }
  }
}
