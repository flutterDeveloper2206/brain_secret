class GetAllFranchisesRequest {
  const GetAllFranchisesRequest({required this.companyCode});

  final int companyCode;

  Map<String, dynamic> toJson() {
    return {'company_code': companyCode};
  }
}
