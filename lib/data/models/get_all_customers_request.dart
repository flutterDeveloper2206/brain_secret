class GetAllCustomersRequest {
  const GetAllCustomersRequest({
    required this.companyCode,
    required this.franchiseCode,
  });

  final int companyCode;
  final int franchiseCode;

  Map<String, dynamic> toJson() {
    return {'company_code': companyCode, 'franchise_code': franchiseCode};
  }
}
