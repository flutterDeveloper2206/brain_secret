class Customer {
  const Customer({
    required this.customerId,
    required this.customerFullName,
    required this.emailId,
    required this.mobileNo,
    required this.gender,
    required this.dob,
    required this.age,
    required this.photoUrl,
    required this.countryName,
    required this.stateName,
    required this.cityName,
    required this.pincode,
    required this.fullAddress,
    required this.occupation,
    required this.organization,
    required this.education,
    required this.maritalStatus,
    required this.preferredLanguage,
    required this.fatherName,
    required this.motherName,
    required this.spouseName,
    required this.emergencyContact,
    required this.anyMedicalIssue,
    required this.anyPsychologicalIssue,
    required this.leftRightHandDominat,
    required this.companyCode,
    required this.franchiseCode,
    this.isActive = true,
    this.isDelete = false,
  });

  final int customerId;
  final String customerFullName;
  final String emailId;
  final String mobileNo;
  final String gender;
  final String dob;
  final int age;
  final String photoUrl;
  final String countryName;
  final String stateName;
  final String cityName;
  final String pincode;
  final String fullAddress;
  final String occupation;
  final String organization;
  final String education;
  final String maritalStatus;
  final String preferredLanguage;
  final String fatherName;
  final String motherName;
  final String spouseName;
  final String emergencyContact;
  final bool anyMedicalIssue;
  final bool anyPsychologicalIssue;
  final bool leftRightHandDominat;
  final int companyCode;
  final int franchiseCode;
  final bool isActive;
  final bool isDelete;

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      customerId: _asInt(
        json['customer_id'] ?? json['id'] ?? json['customerId'],
      ),
      customerFullName: json['customer_full_name']?.toString() ?? '',
      emailId: json['email_id']?.toString() ?? '',
      mobileNo: json['mobile_no']?.toString() ?? '',
      gender: json['gender']?.toString() ?? '',
      dob: json['dob']?.toString() ?? '',
      age: _asInt(json['age']),
      photoUrl: json['photo_url']?.toString() ?? '',
      countryName: json['country_name']?.toString() ?? '',
      stateName: json['state_name']?.toString() ?? '',
      cityName: json['city_name']?.toString() ?? '',
      pincode: json['pincode']?.toString() ?? '',
      fullAddress: json['full_address']?.toString() ?? '',
      occupation: json['occupation']?.toString() ?? '',
      organization: json['organization']?.toString() ?? '',
      education: json['education']?.toString() ?? '',
      maritalStatus: json['marital_status']?.toString() ?? '',
      preferredLanguage: json['preferred_language']?.toString() ?? '',
      fatherName: json['father_name']?.toString() ?? '',
      motherName: json['mother_name']?.toString() ?? '',
      spouseName: json['spouse_name']?.toString() ?? '',
      emergencyContact: json['emergency_contact']?.toString() ?? '',
      anyMedicalIssue: _asBool(json['any_medical_issue']),
      anyPsychologicalIssue: _asBool(json['any_psychological_issue']),
      leftRightHandDominat: _asBool(json['left_right_hand_dominat']),
      companyCode: _asInt(json['company_code']),
      franchiseCode: _asInt(json['franchise_code']),
      // Default active so list/create keep working when API omits the flag.
      isActive: json.containsKey('is_active')
          ? _asBool(json['is_active'])
          : true,
      isDelete: _asBool(json['is_delete']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customer_id': customerId,
      'customer_full_name': customerFullName,
      'email_id': emailId,
      'mobile_no': mobileNo,
      'gender': gender,
      'dob': dob,
      'age': age,
      'photo_url': photoUrl,
      'country_name': countryName,
      'state_name': stateName,
      'city_name': cityName,
      'pincode': pincode,
      'full_address': fullAddress,
      'occupation': occupation,
      'organization': organization,
      'education': education,
      'marital_status': maritalStatus,
      'preferred_language': preferredLanguage,
      'father_name': fatherName,
      'mother_name': motherName,
      'spouse_name': spouseName,
      'emergency_contact': emergencyContact,
      'any_medical_issue': anyMedicalIssue,
      'any_psychological_issue': anyPsychologicalIssue,
      'left_right_hand_dominat': leftRightHandDominat,
      'company_code': companyCode,
      'franchise_code': franchiseCode,
      'is_active': isActive,
      'is_delete': isDelete,
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
    final text = value?.toString().toLowerCase() ?? '';
    return text == 'true' || text == '1' || text == 'yes';
  }
}
