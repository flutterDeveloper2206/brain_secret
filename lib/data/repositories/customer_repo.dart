import '../models/customer_api_response.dart';
import '../models/customer_request.dart';
import '../models/get_all_customers_request.dart';
import '../models/get_all_customers_response.dart';

abstract class CustomerRepository {
  Future<CustomerApiResponse> createCustomer(CustomerRequest request);
  Future<CustomerApiResponse> updateCustomer(CustomerRequest request);
  Future<CustomerApiResponse> deleteCustomer(int customerId);
  Future<GetAllCustomersResponse> getAllCustomers(
    GetAllCustomersRequest request,
  );
  Future<GetCustomerResponse> getCustomer(int customerId);
}
