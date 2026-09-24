class CreateStaffRequest {
  const CreateStaffRequest({
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
  final bool isActive;
  final bool isDelete;

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
}
