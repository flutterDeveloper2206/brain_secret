import 'dart:convert';

import 'package:get/get.dart';

import '../../core/errors/exceptions.dart';
import '../../core/values/app_constants.dart';
import '../models/company_dropdown.dart';
import '../models/create_franchise_request.dart';
import '../models/create_franchise_response.dart';
import '../models/franchise_api_response.dart';
import '../models/franchise_dropdown.dart';
import '../models/get_all_franchises_request.dart';
import '../models/get_all_franchises_response.dart';
import '../providers/api_service.dart';
import 'franchise_repo.dart';

class FranchiseRepositoryImpl implements FranchiseRepository {
  FranchiseRepositoryImpl({required this.apiService});

  final ApiService apiService;

  void _ensureToken() {
    final token = apiService.authToken;
    if (token == null || token.isEmpty) {
      throw ServerException('Authentication token is missing.');
    }
  }

  bool _isEmptyFranchiseListMessage(String message) {
    final normalized = message.toLowerCase().trim();
    return normalized.contains('no franchise') ||
        normalized.contains('franchise not found') ||
        normalized.contains('franchises not found') ||
        normalized.contains('no data found') ||
        normalized.contains('data not found');
  }

  FranchiseApiResponse _parseApiResponse(dynamic body, String fallback) {
    if (body is! Map) {
      throw ServerException(fallback);
    }
    final response = FranchiseApiResponse.fromJson(
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
  Future<CreateFranchiseResponse> createFranchise({
    required CreateFranchiseRequest request,
    required FranchisePanFile panCard,
  }) async {
    try {
      _ensureToken();

      final formData = FormData({
        'data': jsonEncode(request.toJson()),
        'pan_card': MultipartFile(panCard.bytes, filename: panCard.fileName),
      });

      final response = await apiService.safeMultipartPost(
        AppConstants.createFranchiseEndpoint,
        formData,
      );

      final body = response.body;
      if (body is! Map) {
        throw ServerException('Unexpected create franchise response.');
      }

      final createResponse = CreateFranchiseResponse.fromJson(
        Map<String, dynamic>.from(body),
      );

      if (!createResponse.isSuccess) {
        throw ServerException(
          createResponse.message.isEmpty
              ? 'Unable to create franchise.'
              : createResponse.message,
        );
      }

      return createResponse;
    } on AppException {
      rethrow;
    } catch (e) {
      throw ServerException('Unable to create franchise. Please try again.');
    }
  }

  @override
  Future<FranchiseApiResponse> updateFranchise({
    required CreateFranchiseRequest request,
    FranchisePanFile? panCard,
  }) async {
    try {
      _ensureToken();

      final map = <String, dynamic>{
        'data': jsonEncode(request.toJson()),
      };
      if (panCard != null) {
        map['pan_card'] = MultipartFile(
          panCard.bytes,
          filename: panCard.fileName,
        );
      }

      final response = await apiService.safeMultipartPost(
        AppConstants.updateFranchiseEndpoint,
        FormData(map),
      );

      return _parseApiResponse(response.body, 'Unable to update franchise.');
    } on AppException {
      rethrow;
    } catch (e) {
      throw ServerException('Unable to update franchise. Please try again.');
    }
  }

  @override
  Future<GetAllFranchisesResponse> getAllFranchises(
    GetAllFranchisesRequest request,
  ) async {
    try {
      _ensureToken();
      final response = await apiService.safePost(
        AppConstants.getAllFranchisesEndpoint,
        request.toJson(),
      );

      final body = response.body;
      if (body is! Map) {
        throw ServerException('Unexpected get franchises response.');
      }

      final franchisesResponse = GetAllFranchisesResponse.fromJson(
        Map<String, dynamic>.from(body),
      );

      if (!franchisesResponse.isSuccess) {
        if (_isEmptyFranchiseListMessage(franchisesResponse.message)) {
          return GetAllFranchisesResponse(
            statusCode: 200,
            message: franchisesResponse.message,
            franchises: const [],
          );
        }
        throw ServerException(
          franchisesResponse.message.isEmpty
              ? 'Unable to load franchises.'
              : franchisesResponse.message,
        );
      }

      return franchisesResponse;
    } on AppException catch (e) {
      if (_isEmptyFranchiseListMessage(e.message)) {
        return GetAllFranchisesResponse(
          statusCode: 200,
          message: e.message,
          franchises: const [],
        );
      }
      rethrow;
    } catch (e) {
      throw ServerException('Unable to load franchises. Please try again.');
    }
  }

  @override
  Future<GetFranchiseResponse> getFranchise(int franchiseCode) async {
    try {
      _ensureToken();
      final response = await apiService.safeGet(
        '${AppConstants.getFranchiseEndpoint}/$franchiseCode',
      );

      final body = response.body;
      if (body is! Map) {
        throw ServerException('Unexpected get franchise response.');
      }

      final franchiseResponse = GetFranchiseResponse.fromJson(
        Map<String, dynamic>.from(body),
      );

      if (!franchiseResponse.isSuccess) {
        throw ServerException(
          franchiseResponse.message.isEmpty
              ? 'Unable to load franchise.'
              : franchiseResponse.message,
        );
      }

      return franchiseResponse;
    } on AppException {
      rethrow;
    } catch (e) {
      throw ServerException('Unable to load franchise. Please try again.');
    }
  }

  @override
  Future<FranchiseApiResponse> toggleFranchiseActive(int franchiseCode) async {
    try {
      _ensureToken();
      final response = await apiService.safeGet(
        '${AppConstants.activeInactiveFranchiseEndpoint}/$franchiseCode',
      );
      return _parseApiResponse(
        response.body,
        'Unable to update franchise status.',
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw ServerException(
        'Unable to update franchise status. Please try again.',
      );
    }
  }

  @override
  Future<FranchiseApiResponse> softDeleteFranchise(int franchiseCode) async {
    try {
      _ensureToken();
      final response = await apiService.safeGet(
        '${AppConstants.softDeleteFranchiseEndpoint}/$franchiseCode',
      );
      return _parseApiResponse(response.body, 'Unable to delete franchise.');
    } on AppException {
      rethrow;
    } catch (e) {
      throw ServerException('Unable to delete franchise. Please try again.');
    }
  }

  @override
  Future<FranchiseDropdownResponse> getFranchiseDropdown(
    int companyCode,
  ) async {
    try {
      _ensureToken();
      final response = await apiService.safeGet(
        '${AppConstants.franchiseDropdownEndpoint}/$companyCode',
      );

      final body = response.body;
      if (body is! Map) {
        throw ServerException('Unexpected franchise dropdown response.');
      }

      final dropdownResponse = FranchiseDropdownResponse.fromJson(
        Map<String, dynamic>.from(body),
      );

      if (!dropdownResponse.isSuccess) {
        if (_isEmptyFranchiseListMessage(dropdownResponse.message)) {
          return FranchiseDropdownResponse(
            statusCode: 200,
            message: dropdownResponse.message,
            items: const [],
          );
        }
        throw ServerException(
          dropdownResponse.message.isEmpty
              ? 'Unable to load franchise dropdown.'
              : dropdownResponse.message,
        );
      }

      return dropdownResponse;
    } on AppException catch (e) {
      if (_isEmptyFranchiseListMessage(e.message)) {
        return FranchiseDropdownResponse(
          statusCode: 200,
          message: e.message,
          items: const [],
        );
      }
      rethrow;
    } catch (e) {
      throw ServerException(
        'Unable to load franchise dropdown. Please try again.',
      );
    }
  }

  @override
  Future<CompanyDropdownResponse> getCompanyDropdown({
    int parentId = 1,
  }) async {
    try {
      _ensureToken();
      final response = await apiService.safeGet(
        AppConstants.companyDropdownUrl(parentId),
      );

      final body = response.body;
      if (body is! Map) {
        throw ServerException('Unexpected company dropdown response.');
      }

      final dropdownResponse = CompanyDropdownResponse.fromJson(
        Map<String, dynamic>.from(body),
      );

      if (!dropdownResponse.isSuccess) {
        throw ServerException(
          dropdownResponse.message.isEmpty
              ? 'Unable to load company dropdown.'
              : dropdownResponse.message,
        );
      }

      return dropdownResponse;
    } on AppException {
      rethrow;
    } catch (e) {
      throw ServerException(
        'Unable to load company dropdown. Please try again.',
      );
    }
  }
}
