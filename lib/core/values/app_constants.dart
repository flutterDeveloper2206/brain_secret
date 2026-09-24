class AppConstants {
  static const String channelName =
      'com.example.finger_print_scan/ridge_counting';
  static const String apiBaseUrl = 'http://187.127.135.213:6090/api/';
  static const String loginEndpoint = 'auth/mobile/login';
  static const String logoutEndpoint = 'auth/mobile/logout';
  static const String permissionsEndpoint = 'rightsmaster/get/user/permissions';
  static const String createCustomerEndpoint = 'master/create-customer';
  static const String updateCustomerEndpoint = 'master/update-customer';
  static const String deleteCustomerEndpoint = 'master/soft-delete-customer';
  static const String getAllCustomersEndpoint = 'master/get-all-customers';
  static const String getCustomerEndpoint = 'master/get-customer';
  static const String createStaffEndpoint = 'master/create-staff';
  static const String updateStaffEndpoint = 'master/update-staff';
  static const String getAllStaffEndpoint = 'master/get-all-staff';
  static const String getStaffEndpoint = 'master/get-staff';
  static const String activeInactiveStaffEndpoint =
      'master/active-inactive-staff';
  static const String softDeleteStaffEndpoint = 'master/soft-delete-staff';
  static const String staffDropdownEndpoint = 'master/dropdown-staff';
  static const String createFranchiseEndpoint = 'entity/create-franchise';
  static const String updateFranchiseEndpoint = 'entity/update-franchise';
  static const String getAllFranchisesEndpoint = 'entity/get-all-franchise';
  static const String getFranchiseEndpoint = 'entity/get-franchise';
  static const String activeInactiveFranchiseEndpoint =
      'entity/active-inactive-franchise';
  static const String softDeleteFranchiseEndpoint =
      'entity/soft-delete-franchise';
  static const String franchiseDropdownEndpoint = 'entity/dropdown/franchise';
  static const String appName = 'Brain Secret';
  static const String appTagline = 'Fingerprint Ridge Counter';
  static const String appVersion = '1.0.0';
  static const double breakpointTablet = 768;
  static const Duration splashDuration = Duration(seconds: 2);

  static const String customerProfile = 'Customer Profile';
  static const String franchiseProfile = 'Franchise Profile';
  static const String staffProfile = 'Staff Profile';
}
