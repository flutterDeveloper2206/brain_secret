import '../../core/errors/exceptions.dart';
import '../../core/values/app_constants.dart';
import '../models/customer_api_response.dart';
import '../models/customer_request.dart';
import '../models/get_all_customers_request.dart';
import '../models/get_all_customers_response.dart';
import '../providers/api_service.dart';
import 'customer_repo.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  CustomerRepositoryImpl({required this.apiService});

  final ApiService apiService;

  void _ensureToken() {
    final token = apiService.authToken;
    if (token == null || token.isEmpty) {
      throw ServerException('Authentication token is missing.');
    }
  }

  bool _isEmptyListMessage(String message) {
    final normalized = message.toLowerCase().trim();
    return normalized.contains('no customer') ||
        normalized.contains('customer not found') ||
        normalized.contains('customers not found') ||
        normalized.contains('no data found') ||
        normalized.contains('data not found') ||
        normalized.contains('not found');
  }

  CustomerApiResponse _parseApiResponse(dynamic body, String fallback) {
    if (body is! Map) {
      throw ServerException(fallback);
    }
    final response = CustomerApiResponse.fromJson(
      Map<String, dynamic>.from(body),
    );
    if (!response.isSuccess) {
      throw ServerException(
        response.message.isEmpty ? fallback : response.message,
      );
    }
    return response;
  }

  @override
  Future<CustomerApiResponse> createCustomer(CustomerRequest request) async {
    try {
      _ensureToken();
      final response = await apiService.safePost(
        AppConstants.createCustomerEndpoint,
        request.toJson(),
      );
      return _parseApiResponse(response.body, 'Unable to create customer.');
    } on AppException {
      rethrow;
    } catch (e) {
      throw ServerException('Unable to create customer. Please try again.');
    }
  }

  @override
  Future<CustomerApiResponse> updateCustomer(CustomerRequest request) async {
    try {
      _ensureToken();
      if (request.customerId <= 0) {
        throw ServerException('Customer id is required for update.');
      }

      final body = request.toJson();
      body['customer_id'] = request.customerId;

      final response = await apiService.safePost(
        AppConstants.updateCustomerEndpoint,
        body,
      );
      return _parseApiResponse(response.body, 'Unable to update customer.');
    } on AppException {
      rethrow;
    } catch (e) {
      throw ServerException('Unable to update customer. Please try again.');
    }
  }

  @override
  Future<CustomerApiResponse> deleteCustomer(int customerId) async {
    try {
      _ensureToken();
      final response = await apiService.safeGet(
        '${AppConstants.deleteCustomerEndpoint}/$customerId',
      );
      return _parseApiResponse(response.body, 'Unable to delete customer.');
    } on AppException {
      rethrow;
    } catch (e) {
      throw ServerException('Unable to delete customer. Please try again.');
    }
  }

  @override
  Future<GetAllCustomersResponse> getAllCustomers(
    GetAllCustomersRequest request,
  ) async {
    try {
      _ensureToken();
      final response = await apiService.safePost(
        AppConstants.getAllCustomersEndpoint,
        request.toJson(),
      );

      final body = response.body;
      if (body is! Map) {
        throw ServerException('Unexpected get customers response.');
      }

      final customersResponse = GetAllCustomersResponse.fromJson(
        Map<String, dynamic>.from(body),
      );

      if (!customersResponse.isSuccess) {
        if (_isEmptyListMessage(customersResponse.message)) {
          return GetAllCustomersResponse(
            statusCode: 200,
            message: customersResponse.message,
            customers: const [],
          );
        }
        throw ServerException(
          customersResponse.message.isEmpty
              ? 'Unable to load customers.'
              : customersResponse.message,
        );
      }

      return customersResponse;
    } on AppException catch (e) {
      if (_isEmptyListMessage(e.message)) {
        return GetAllCustomersResponse(
          statusCode: 200,
          message: e.message,
          customers: const [],
        );
      }
      rethrow;
    } catch (e) {
      throw ServerException('Unable to load customers. Please try again.');
    }
  }

  @override
  Future<GetCustomerResponse> getCustomer(int customerId) async {
    try {
      _ensureToken();
      final response = await apiService.safeGet(
        '${AppConstants.getCustomerEndpoint}/$customerId',
      );

      final body = response.body;
      if (body is! Map) {
        throw ServerException('Unexpected get customer response.');
      }

      final customerResponse = GetCustomerResponse.fromJson(
        Map<String, dynamic>.from(body),
      );

      if (!customerResponse.isSuccess) {
        throw ServerException(
          customerResponse.message.isEmpty
              ? 'Customer not found.'
              : customerResponse.message,
        );
      }

      return customerResponse;
    } on AppException {
      rethrow;
    } catch (e) {
      throw ServerException(
        'Unable to load customer details. Please try again.',
      );
    }
  }
}
