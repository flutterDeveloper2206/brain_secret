import '../../core/errors/exceptions.dart';
import '../../core/values/app_constants.dart';
import '../models/create_staff_request.dart';
import '../models/get_all_staff_request.dart';
import '../models/get_all_staff_response.dart';
import '../models/staff_api_response.dart';
import '../models/staff_dropdown.dart';
import '../providers/api_service.dart';
import 'staff_repo.dart';

class StaffRepositoryImpl implements StaffRepository {
  StaffRepositoryImpl({required this.apiService});

  final ApiService apiService;

  void _ensureToken() {
    final token = apiService.authToken;
    if (token == null || token.isEmpty) {
      throw ServerException('Authentication token is missing.');
    }
  }

  bool _isEmptyListMessage(String message) {
    final normalized = message.toLowerCase().trim();
    return normalized.contains('no staff') ||
        normalized.contains('staff not found') ||
        normalized.contains('no employee') ||
        normalized.contains('employees not found') ||
        normalized.contains('no data found') ||
        normalized.contains('data not found') ||
        normalized.contains('not found');
  }

  StaffApiResponse _parseApiResponse(dynamic body, String fallback) {
    if (body is! Map) {
      throw ServerException(fallback);
    }
    final response = StaffApiResponse.fromJson(
      Map<String, dynamic>.from(body),
    );
    if (!response.isSuccess) {
      throw ServerException(
        response.message.isEmpty ? fallback : response.message,
        statusCode: response.statusCode,
      );
    }
    return response;
  }

  @override
  Future<StaffApiResponse> createStaff(CreateStaffRequest request) async {
    try {
      _ensureToken();
      final response = await apiService.safePost(
        AppConstants.createStaffEndpoint,
        request.toJson(),
      );
      return _parseApiResponse(response.body, 'Unable to create staff.');
    } on AppException {
      rethrow;
    } catch (e) {
      throw ServerException('Unable to create staff. Please try again.');
    }
  }

  @override
  Future<StaffApiResponse> updateStaff(CreateStaffRequest request) async {
    try {
      _ensureToken();
      if (request.employeeId <= 0) {
        throw ServerException('Employee id is required for update.');
      }

      final body = request.toJson();
      body['employee_id'] = request.employeeId;

      final response = await apiService.safePost(
        AppConstants.updateStaffEndpoint,
        body,
      );
      return _parseApiResponse(response.body, 'Unable to update staff.');
    } on AppException {
      rethrow;
    } catch (e) {
      throw ServerException('Unable to update staff. Please try again.');
    }
  }

  @override
  Future<GetAllStaffResponse> getAllStaff(GetAllStaffRequest request) async {
    try {
      _ensureToken();
      final response = await apiService.safePost(
        AppConstants.getAllStaffEndpoint,
        request.toJson(),
      );

      final body = response.body;
      if (body is! Map) {
        throw ServerException('Unexpected get staff response.');
      }

      final staffResponse = GetAllStaffResponse.fromJson(
        Map<String, dynamic>.from(body),
      );

      if (!staffResponse.isSuccess) {
        if (_isEmptyListMessage(staffResponse.message)) {
          return GetAllStaffResponse(
            statusCode: 200,
            message: staffResponse.message,
            staffList: const [],
          );
        }
        throw ServerException(
          staffResponse.message.isEmpty
              ? 'Unable to load staff.'
              : staffResponse.message,
          statusCode: staffResponse.statusCode,
        );
      }

      return staffResponse;
    } on AppException catch (e) {
      if (_isEmptyListMessage(e.message)) {
        return GetAllStaffResponse(
          statusCode: 200,
          message: e.message,
          staffList: const [],
        );
      }
      rethrow;
    } catch (e) {
      throw ServerException('Unable to load staff. Please try again.');
    }
  }

  @override
  Future<GetStaffResponse> getStaff(int employeeId) async {
    try {
      _ensureToken();
      final response = await apiService.safeGet(
        '${AppConstants.getStaffEndpoint}/$employeeId',
      );

      final body = response.body;
      if (body is! Map) {
        throw ServerException('Unexpected get staff response.');
      }

      final staffResponse = GetStaffResponse.fromJson(
        Map<String, dynamic>.from(body),
      );

      if (!staffResponse.isSuccess) {
        throw ServerException(
          staffResponse.message.isEmpty
              ? 'Staff not found.'
              : staffResponse.message,
          statusCode: staffResponse.statusCode,
        );
      }

      return staffResponse;
    } on AppException {
      rethrow;
    } catch (e) {
      throw ServerException('Unable to load staff details. Please try again.');
    }
  }

  @override
  Future<StaffApiResponse> toggleStaffActive(int employeeId) async {
    try {
      _ensureToken();
      final response = await apiService.safeGet(
        '${AppConstants.activeInactiveStaffEndpoint}/$employeeId',
      );
      return _parseApiResponse(
        response.body,
        'Unable to update staff status.',
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw ServerException('Unable to update staff status. Please try again.');
    }
  }

  @override
  Future<StaffApiResponse> softDeleteStaff(int employeeId) async {
    try {
      _ensureToken();
      final response = await apiService.safeGet(
        '${AppConstants.softDeleteStaffEndpoint}/$employeeId',
      );
      return _parseApiResponse(response.body, 'Unable to delete staff.');
    } on AppException {
      rethrow;
    } catch (e) {
      throw ServerException('Unable to delete staff. Please try again.');
    }
  }

  @override
  Future<StaffDropdownResponse> getStaffDropdown(int companyCode) async {
    try {
      _ensureToken();
      final response = await apiService.safeGet(
        '${AppConstants.staffDropdownEndpoint}/$companyCode',
      );

      final body = response.body;
      if (body is! Map) {
        throw ServerException('Unexpected staff dropdown response.');
      }

      final dropdownResponse = StaffDropdownResponse.fromJson(
        Map<String, dynamic>.from(body),
      );

      if (!dropdownResponse.isSuccess) {
        if (_isEmptyListMessage(dropdownResponse.message)) {
          return StaffDropdownResponse(
            statusCode: 200,
            message: dropdownResponse.message,
            items: const [],
          );
        }
        throw ServerException(
          dropdownResponse.message.isEmpty
              ? 'Unable to load staff dropdown.'
              : dropdownResponse.message,
          statusCode: dropdownResponse.statusCode,
        );
      }

      return dropdownResponse;
    } on AppException catch (e) {
      if (_isEmptyListMessage(e.message)) {
        return StaffDropdownResponse(
          statusCode: 200,
          message: e.message,
          items: const [],
        );
      }
      rethrow;
    } catch (e) {
      throw ServerException(
        'Unable to load staff dropdown. Please try again.',
      );
    }
  }
}
