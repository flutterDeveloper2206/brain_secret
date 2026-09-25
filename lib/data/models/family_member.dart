class FamilyMember {
  const FamilyMember({
    required this.customerFullName,
    required this.emailId,
    required this.education,
    required this.age,
    required this.emergencyContact,
    required this.dob,
  });

  final String customerFullName;
  final String emailId;
  final String education;
  final int age;
  final String emergencyContact;
  final String dob;

  factory FamilyMember.fromJson(Map<String, dynamic> json) {
    return FamilyMember(
      customerFullName: json['customer_full_name']?.toString() ?? '',
      emailId: json['email_id']?.toString() ?? '',
      education: json['education']?.toString() ?? '',
      age: _asInt(json['age']),
      emergencyContact: json['emergency_contact']?.toString() ?? '',
      dob: json['dob']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customer_full_name': customerFullName,
      'email_id': emailId,
      'education': education,
      'age': age,
      'emergency_contact': emergencyContact,
      'dob': dob,
    };
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
