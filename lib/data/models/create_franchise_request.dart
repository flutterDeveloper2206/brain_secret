class CreateFranchiseRequest {
  const CreateFranchiseRequest({
    required this.franchiseCode,
    required this.companyCode,
    required this.franchiseName,
    required this.ownerName,
    required this.gstNumber,
    required this.mobileNo,
    required this.emailId,
    required this.website,
    required this.country,
    required this.state,
    required this.city,
    required this.fullAddress,
    required this.pincode,
    required this.bankName,
    required this.accountHolderName,
    required this.accountNumber,
    required this.ifscCode,
    required this.isActive,
    required this.isDelete,
  });

  final int franchiseCode;
  final int companyCode;
  final String franchiseName;
  final String ownerName;
  final String gstNumber;
  final String mobileNo;
  final String emailId;
  final String website;
  final String country;
  final String state;
  final String city;
  final String fullAddress;
  final String pincode;
  final String bankName;
  final String accountHolderName;
  final String accountNumber;
  final String ifscCode;
  final bool isActive;
  final bool isDelete;

  Map<String, dynamic> toJson() {
    return {
      'franchise_code': franchiseCode,
      'company_code': companyCode,
      'franchise_name': franchiseName,
      'owner_name': ownerName,
      'gst_number': gstNumber,
      'mobile_no': mobileNo,
      'email_id': emailId,
      'website': website,
      'country': country,
      'state': state,
      'city': city,
      'full_address': fullAddress,
      'pincode': pincode,
      'bank_name': bankName,
      'account_holder_name': accountHolderName,
      'account_number': accountNumber,
      'ifsc_code': ifscCode,
      'is_active': isActive,
      'is_delete': isDelete,
    };
  }
}
