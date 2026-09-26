import 'user_master_account.dart';

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
    this.masterDataRaw = const [],
  });

  final int userCode;
  final String userName;
  final String? fullName;
  final String emailId;
  final String mobileNo;
  final String userType;
  final String? profilePhotoUrl;
  final String? memberSince;
  final List<Map<String, dynamic>> masterDataRaw;

  String get displayName {
    final name = fullName?.trim();
    if (name != null && name.isNotEmpty) return name;
    if (userName.isNotEmpty) return userName;
    return 'User';
  }

  String get normalizedUserType => userType.trim().toUpperCase();

  bool get isCustomer => normalizedUserType == 'CUSTOMER';
  bool get isFranchise => normalizedUserType == 'FRANCHISE';
  bool get isStaff => normalizedUserType == 'STAFF';

  List<UserMasterAccount> get accounts {
    return masterDataRaw
        .map((raw) => UserMasterAccount.fromJson(normalizedUserType, raw))
        .where((a) => a.id > 0 || a.displayName.isNotEmpty)
        .toList();
  }

  /// Preferred default account id for this profile.
  int? get defaultAccountId {
    final list = accounts;
    if (list.isEmpty) return null;
    if (isCustomer) {
      for (final account in list) {
        if (account.parentId == 0) return account.id;
      }
    }
    return list.first.id;
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final rawMaster = json['master_data'] ?? json['masterData'];
    final masterList = <Map<String, dynamic>>[];
    if (rawMaster is List) {
      for (final item in rawMaster) {
        if (item is Map) {
          masterList.add(Map<String, dynamic>.from(item));
        }
      }
    }

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
      masterDataRaw: masterList,
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
      'master_data': masterDataRaw,
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
