import '../models/create_staff_request.dart';
import '../models/get_all_staff_request.dart';
import '../models/get_all_staff_response.dart';
import '../models/staff_api_response.dart';
import '../models/staff_dropdown.dart';

abstract class StaffRepository {
  Future<StaffApiResponse> createStaff(CreateStaffRequest request);

  Future<StaffApiResponse> updateStaff(CreateStaffRequest request);

  Future<GetAllStaffResponse> getAllStaff(GetAllStaffRequest request);

  Future<GetStaffResponse> getStaff(int employeeId);

  Future<StaffApiResponse> toggleStaffActive(int employeeId);

  Future<StaffApiResponse> softDeleteStaff(int employeeId);

  Future<StaffDropdownResponse> getStaffDropdown(int companyCode);
}
