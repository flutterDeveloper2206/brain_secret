class GetAllStaffRequest {
  const GetAllStaffRequest({this.companyCode});

  final int? companyCode;

  Map<String, dynamic> toJson() {
    if (companyCode == null) return <String, dynamic>{};
    return {'company_code': companyCode};
  }
}
