import 'dart:typed_data';

import '../models/company_dropdown.dart';
import '../models/create_franchise_request.dart';
import '../models/create_franchise_response.dart';
import '../models/franchise_api_response.dart';
import '../models/franchise_dropdown.dart';
import '../models/get_all_franchises_request.dart';
import '../models/get_all_franchises_response.dart';

class FranchisePanFile {
  const FranchisePanFile({required this.bytes, required this.fileName});

  final Uint8List bytes;
  final String fileName;
}

abstract class FranchiseRepository {
  Future<CreateFranchiseResponse> createFranchise({
    required CreateFranchiseRequest request,
    required FranchisePanFile panCard,
  });

  Future<FranchiseApiResponse> updateFranchise({
    required CreateFranchiseRequest request,
    FranchisePanFile? panCard,
  });

  Future<GetAllFranchisesResponse> getAllFranchises(
    GetAllFranchisesRequest request,
  );

  Future<GetFranchiseResponse> getFranchise(int franchiseCode);

  Future<FranchiseApiResponse> toggleFranchiseActive(int franchiseCode);

  Future<FranchiseApiResponse> softDeleteFranchise(int franchiseCode);

  Future<FranchiseDropdownResponse> getFranchiseDropdown(int companyCode);

  Future<CompanyDropdownResponse> getCompanyDropdown({int parentId = 1});
}
