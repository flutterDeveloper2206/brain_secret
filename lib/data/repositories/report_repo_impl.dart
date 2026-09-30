import '../../core/errors/exceptions.dart';
import '../../core/values/app_constants.dart';
import '../models/customer_report.dart';
import '../providers/api_service.dart';
import 'report_repo.dart';

class ReportRepositoryImpl implements ReportRepository {
  ReportRepositoryImpl({required this.apiService});

  final ApiService apiService;

  void _ensureToken() {
    final token = apiService.authToken;
    if (token == null || token.isEmpty) {
      throw ServerException('Authentication token is missing.');
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
  Future<bool> generateAllReports(int customerId) async {
    try {
      _ensureToken();
      final response = await apiService.safePost(
        AppConstants.generateAllReportsEndpoint(customerId),
        <String, dynamic>{},
      );

      _ensureEnvelopeSuccess(
        response.body,
        'Unable to generate reports.',
      );

      final httpCode = response.statusCode ?? 0;
      if (httpCode == 200 || httpCode == 201) return true;

      final body = response.body;
      if (body is Map) {
        final status = body['statusCode'] ?? body['status_code'];
        final code = status is int
            ? status
            : int.tryParse(status?.toString() ?? '') ?? 0;
        if (code == 200 || code == 201) return true;
      }

      return true;
    } on AppException {
      rethrow;
    } catch (e) {
      throw ServerException('Unable to generate reports. Please try again.');
    }
  }

  @override
  Future<List<CustomerReport>> getCustomerReports(int customerId) async {
    try {
      _ensureToken();
      final response = await apiService.safeGet(
        AppConstants.customerReportsEndpoint(customerId),
      );

      final body = response.body;
      if (body is! Map) {
        throw ServerException('Unexpected customer reports response.');
      }

      _ensureEnvelopeSuccess(body, 'Unable to load customer reports.');

      final raw = body['data'];
      if (raw is! List) return const [];

      return raw
          .whereType<Map>()
          .map(
            (item) => CustomerReport.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();
    } on AppException {
      rethrow;
    } catch (e) {
      throw ServerException(
        'Unable to load customer reports. Please try again.',
      );
    }
  }
}
