class Franchise {
  const Franchise({
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
    this.panCardUrl = '',
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
  final String panCardUrl;

  factory Franchise.fromJson(Map<String, dynamic> json) {
    return Franchise(
      franchiseCode: _asInt(json['franchise_code']),
      companyCode: _asInt(json['company_code']),
      franchiseName: json['franchise_name']?.toString() ?? '',
      ownerName: json['owner_name']?.toString() ?? '',
      gstNumber: json['gst_number']?.toString() ?? '',
      mobileNo: json['mobile_no']?.toString() ?? '',
      emailId: json['email_id']?.toString() ?? '',
      website: json['website']?.toString() ?? '',
      country: json['country']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      fullAddress: json['full_address']?.toString() ?? '',
      pincode: json['pincode']?.toString() ?? '',
      bankName: json['bank_name']?.toString() ?? '',
      accountHolderName: json['account_holder_name']?.toString() ?? '',
      accountNumber: json['account_number']?.toString() ?? '',
      ifscCode: json['ifsc_code']?.toString() ?? '',
      isActive: _asBool(json['is_active']),
      isDelete: _asBool(json['is_delete']),
      panCardUrl:
          json['pan_card_url']?.toString() ??
          json['pan_card']?.toString() ??
          '',
    );
  }

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
      'pan_card_url': panCardUrl,
    };
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static bool _asBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    final text = value?.toString().toLowerCase().trim() ?? '';
    return text == 'true' || text == '1' || text == 'yes';
  }
}
