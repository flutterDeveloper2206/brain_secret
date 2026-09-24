class Staff {
  const Staff({
    required this.employeeId,
    required this.companyCode,
    required this.employeeFullName,
    required this.gender,
    required this.dob,
    required this.mobileNo,
    required this.emailId,
    required this.departmentName,
    required this.designationName,
    required this.joiningDate,
    this.employeePhoto = '',
    this.userCode = 0,
    this.isActive = true,
    this.isDelete = false,
  });

  final int employeeId;
  final int companyCode;
  final String employeeFullName;
  final String gender;
  final String dob;
  final String mobileNo;
  final String emailId;
  final String departmentName;
  final String designationName;
  final String joiningDate;
  final String employeePhoto;
  final int userCode;
  final bool isActive;
  final bool isDelete;

  factory Staff.fromJson(Map<String, dynamic> json) {
    return Staff(
      employeeId: _asInt(
        json['employee_id'] ?? json['id'] ?? json['employeeId'],
      ),
      companyCode: _asInt(json['company_code']),
      employeeFullName: json['employee_full_name']?.toString() ?? '',
      gender: json['gender']?.toString() ?? '',
      dob: json['dob']?.toString() ?? '',
      mobileNo: json['mobile_no']?.toString() ?? '',
      emailId: json['email_id']?.toString() ?? '',
      departmentName: json['department_name']?.toString() ?? '',
      designationName: json['designation_name']?.toString() ?? '',
      joiningDate: json['joining_date']?.toString() ?? '',
      employeePhoto: json['employee_photo']?.toString() ?? '',
      userCode: _asInt(json['user_code']),
      isActive: json.containsKey('is_active')
          ? _asBool(json['is_active'])
          : true,
      isDelete: _asBool(json['is_delete']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'employee_id': employeeId,
      'company_code': companyCode,
      'employee_full_name': employeeFullName,
      'gender': gender,
      'dob': dob,
      'mobile_no': mobileNo,
      'email_id': emailId,
      'department_name': departmentName,
      'designation_name': designationName,
      'joining_date': joiningDate,
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
