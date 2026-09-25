class UserProfile {
  const UserProfile({
    required this.userCode,
    required this.userName,
    this.fullName,
    required this.emailId,
    required this.mobileNo,
    required this.userType,
    this.profilePhotoUrl,
    this.memberSince,
  });

  final int userCode;
  final String userName;
  final String? fullName;
  final String emailId;
  final String mobileNo;
  final String userType;
  final String? profilePhotoUrl;
  final String? memberSince;

  String get displayName {
    final name = fullName?.trim();
    if (name != null && name.isNotEmpty) return name;
    if (userName.isNotEmpty) return userName;
    return 'User';
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userCode: _asInt(json['user_code'] ?? json['userCode']),
      userName: json['user_name']?.toString() ?? json['userName']?.toString() ?? '',
      fullName: _nullableString(json['full_name'] ?? json['fullName']),
      emailId: json['email_id']?.toString() ?? json['emailId']?.toString() ?? '',
      mobileNo:
          json['mobile_no']?.toString() ?? json['mobileNo']?.toString() ?? '',
      userType:
          json['user_type']?.toString() ?? json['userType']?.toString() ?? '',
      profilePhotoUrl: _nullableString(
        json['profile_photo_url'] ?? json['profilePhotoUrl'],
      ),
      memberSince: _nullableString(
        json['member_since'] ?? json['memberSince'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_code': userCode,
      'user_name': userName,
      'full_name': fullName,
      'email_id': emailId,
      'mobile_no': mobileNo,
      'user_type': userType,
      'profile_photo_url': profilePhotoUrl,
      'member_since': memberSince,
    };
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static String? _nullableString(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    if (text.isEmpty || text == 'null') return null;
    return text;
  }
}
