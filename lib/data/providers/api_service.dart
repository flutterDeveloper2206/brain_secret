import 'package:get/get.dart';
import '../../core/errors/exceptions.dart';
import '../../core/values/app_constants.dart';

class ApiService extends GetConnect {
  @override
  void onInit() {
    httpClient.baseUrl = AppConstants.apiBaseUrl;
    httpClient.timeout = const Duration(seconds: 15);
    super.onInit();
  }

  Future<Response> safeGet(String url) async {
    try {
      final response = await get(url);
      return _handleResponse(response);
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException("Failed to reach the server. Please check your internet connection.");
    }
  }

  Future<Response> safePost(String url, dynamic body) async {
    try {
      final response = await post(url, body);
      return _handleResponse(response);
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException("Failed to submit data to the server. Please check your internet connection.");
    }
  }

  Response _handleResponse(Response response) {
    if (response.status.hasError) {
      if (response.status.connectionError) {
        throw NetworkException("No internet connection available.");
      }
      throw ServerException("Request failed with status code: ${response.statusCode}");
    }
    return response;
  }
}
