import 'customer.dart';

class CustomerRequest {
  const CustomerRequest({
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

  Map<String, dynamic> toJson() {
    return Customer(
      customerId: customerId,
      customerFullName: customerFullName,
      emailId: emailId,
      mobileNo: mobileNo,
      gender: gender,
      dob: dob,
      age: age,
      photoUrl: photoUrl,
      countryName: countryName,
      stateName: stateName,
      cityName: cityName,
      pincode: pincode,
      fullAddress: fullAddress,
      occupation: occupation,
      organization: organization,
      education: education,
      maritalStatus: maritalStatus,
      preferredLanguage: preferredLanguage,
      fatherName: fatherName,
      motherName: motherName,
      spouseName: spouseName,
      emergencyContact: emergencyContact,
      anyMedicalIssue: anyMedicalIssue,
      anyPsychologicalIssue: anyPsychologicalIssue,
      leftRightHandDominat: leftRightHandDominat,
      companyCode: companyCode,
      franchiseCode: franchiseCode,
      isActive: isActive,
      isDelete: isDelete,
    ).toJson();
  }
}
