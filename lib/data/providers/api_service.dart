import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../core/errors/exceptions.dart';
import '../../core/values/app_constants.dart';

class ApiService extends GetConnect {
  @override
  void onInit() {
    httpClient.baseUrl = AppConstants.apiBaseUrl;
    httpClient.timeout = const Duration(seconds: 20);
    httpClient.defaultContentType = 'application/json';
    super.onInit();
  }

  String? _authToken;

  void setAuthToken(String? token) {
    _authToken = token;
  }

  String? get authToken => _authToken;

  Map<String, String> get _headers {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    // Backend expects Authentication header (not Bearer Authorization).
    if (_authToken != null && _authToken!.isNotEmpty) {
      headers['Authentication'] = _authToken!;
    }
    return headers;
  }

  Map<String, String> get _multipartHeaders {
    final headers = <String, String>{'Accept': 'application/json'};
    if (_authToken != null && _authToken!.isNotEmpty) {
      headers['Authentication'] = _authToken!;
    }
    return headers;
  }

  String _absoluteUrl(String url) {
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }
    final base = AppConstants.apiBaseUrl;
    if (base.endsWith('/') && url.startsWith('/')) {
      return '$base${url.substring(1)}';
    }
    if (!base.endsWith('/') && !url.startsWith('/')) {
      return '$base/$url';
    }
    return '$base$url';
  }

  void _logRequest(String method, String url, Map<String, String> headers) {
    if (!kDebugMode) return;
    debugPrint('━━━━━━━━ API REQUEST ━━━━━━━━');
    debugPrint('Method : $method');
    debugPrint('URL    : ${_absoluteUrl(url)}');
    debugPrint('Headers: $headers');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  }

  void _logResponse(String method, String url, Response response) {
    if (!kDebugMode) return;
    debugPrint('━━━━━━━━ API RESPONSE ━━━━━━━');
    debugPrint('Method : $method');
    debugPrint('URL    : ${_absoluteUrl(url)}');
    debugPrint('Status : ${response.statusCode}');
    debugPrint('Body   : ${response.body}');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  }

  Future<Response> safeGet(String url) async {
    final headers = _headers;
    _logRequest('GET', url, headers);
    try {
      final response = await get(url, headers: headers);
      _logResponse('GET', url, response);
      return _handleResponse(response);
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException(
        'Failed to reach the server. Please check your internet connection.',
      );
    }
  }

  Future<Response> safePost(String url, dynamic body) async {
    final headers = _headers;
    _logRequest('POST', url, headers);
    if (kDebugMode) {
      debugPrint('Body   : $body');
    }
    try {
      final response = await post(url, body, headers: headers);
      _logResponse('POST', url, response);
      return _handleResponse(response);
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException(
        'Failed to submit data to the server. Please check your internet connection.',
      );
    }
  }

  Future<Response> safeMultipartPost(String url, FormData formData) async {
    final headers = _multipartHeaders;
    _logRequest('POST (multipart)', url, headers);
    if (kDebugMode) {
      debugPrint(
        'Form   : ${formData.fields} / files=${formData.files.length}',
      );
    }
    try {
      final response = await post(url, formData, headers: headers);
      _logResponse('POST (multipart)', url, response);
      return _handleResponse(response);
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException(
        'Failed to submit data to the server. Please check your internet connection.',
      );
    }
  }

  /// Handles both HTTP status codes and API envelope `statusCode` in the body
  /// (this backend often returns HTTP 200 with `statusCode: 500` in JSON).
  Response _handleResponse(Response response) {
    if (response.status.connectionError) {
      throw NetworkException('No internet connection available.');
    }

    final httpCode = response.statusCode ?? 0;
    final body = response.body;
    final apiStatus = _readApiStatus(body);
    final apiMessage = _readApiMessage(body);

    final httpFailed = response.status.hasError;
    final apiFailed =
        apiStatus != null && apiStatus != 200 && apiStatus != 201;

    if (!httpFailed && !apiFailed) {
      return response;
    }

    final statusCode = httpFailed && httpCode > 0
        ? httpCode
        : (apiStatus ?? httpCode);
    final message = _resolveErrorMessage(
      statusCode: statusCode,
      apiMessage: apiMessage,
      body: body,
    );

    throw _exceptionForStatus(statusCode, message);
  }

  int? _readApiStatus(dynamic body) {
    if (body is! Map) return null;
    final raw = body['statusCode'] ?? body['status_code'] ?? body['code'];
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    return int.tryParse(raw?.toString() ?? '');
  }

  String? _readApiMessage(dynamic body) {
    if (body is Map) {
      final message =
          body['message'] ??
          body['error'] ??
          body['error_message'] ??
          body['title'];
      final text = message?.toString().trim();
      if (text != null && text.isNotEmpty) return text;
    }
    if (body is String) {
      final text = body.trim();
      if (text.isNotEmpty && !text.startsWith('<')) return text;
    }
    return null;
  }

  String _resolveErrorMessage({
    required int statusCode,
    required String? apiMessage,
    required dynamic body,
  }) {
    if (apiMessage != null && apiMessage.isNotEmpty) {
      return apiMessage;
    }

    switch (statusCode) {
      case 400:
        return 'Invalid request. Please check the details and try again.';
      case 401:
        return 'Your session has expired. Please sign in again.';
      case 403:
        return 'You do not have permission to perform this action.';
      case 404:
        return 'The requested resource was not found.';
      case 408:
      case 504:
        return 'The server took too long to respond. Please try again.';
      case 409:
        return 'This record already exists or conflicts with existing data.';
      case 422:
        return 'Some fields are invalid. Please review and try again.';
      case 429:
        return 'Too many requests. Please wait a moment and try again.';
      case 500:
      case 502:
      case 503:
        return 'Something went wrong on the server. Please try again later.';
      default:
        if (statusCode >= 500) {
          return 'Something went wrong on the server. Please try again later.';
        }
        if (statusCode >= 400) {
          return 'Request failed. Please try again.';
        }
        return body?.toString().trim().isNotEmpty == true
            ? body.toString()
            : 'Something went wrong. Please try again.';
    }
  }

  Never _exceptionForStatus(int statusCode, String message) {
    if (statusCode == 401) {
      throw UnauthorizedException(message, statusCode: statusCode);
    }
    if (statusCode == 403) {
      throw ForbiddenException(message, statusCode: statusCode);
    }
    if (statusCode == 404) {
      throw NotFoundException(message, statusCode: statusCode);
    }
    if (statusCode == 400 || statusCode == 422) {
      throw ValidationException(message, statusCode: statusCode);
    }
    if (statusCode == 408 || statusCode == 504) {
      throw NetworkException(message, statusCode: statusCode);
    }
    throw ServerException(message, statusCode: statusCode);
  }
}
