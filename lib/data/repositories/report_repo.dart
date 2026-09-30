import '../models/customer_report.dart';

abstract class ReportRepository {
  Future<bool> generateAllReports(int customerId);

  Future<List<CustomerReport>> getCustomerReports(int customerId);
}
