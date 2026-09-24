import 'customer.dart';

class GetAllCustomersResponse {
  const GetAllCustomersResponse({
    required this.statusCode,
    required this.message,
    required this.customers,
  });

  final int statusCode;
  final String message;
  final List<Customer> customers;

  bool get isSuccess => statusCode == 200 || statusCode == 201;

  factory GetAllCustomersResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    final list = <Customer>[];

    if (rawData is List) {
      for (final item in rawData) {
        if (item is Map) {
          list.add(Customer.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    } else if (rawData is Map) {
      final nested =
          rawData['customers'] ??
          rawData['customerList'] ??
          rawData['list'] ??
          rawData['items'];
      if (nested is List) {
        for (final item in nested) {
          if (item is Map) {
            list.add(Customer.fromJson(Map<String, dynamic>.from(item)));
          }
        }
      } else {
        list.add(Customer.fromJson(Map<String, dynamic>.from(rawData)));
      }
    }

    return GetAllCustomersResponse(
      statusCode: json['statusCode'] as int? ?? 0,
      message: json['message'] as String? ?? 'Unknown response',
      customers: list,
    );
  }
}

class GetCustomerResponse {
  const GetCustomerResponse({
    required this.statusCode,
    required this.message,
    this.customer,
  });

  final int statusCode;
  final String message;
  final Customer? customer;

  bool get isSuccess =>
      (statusCode == 200 || statusCode == 201) && customer != null;

  factory GetCustomerResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    Customer? customer;

    if (rawData is Map) {
      customer = Customer.fromJson(Map<String, dynamic>.from(rawData));
    } else if (rawData is List && rawData.isNotEmpty && rawData.first is Map) {
      customer = Customer.fromJson(
        Map<String, dynamic>.from(rawData.first as Map),
      );
    }

    return GetCustomerResponse(
      statusCode: json['statusCode'] as int? ?? 0,
      message: json['message'] as String? ?? 'Unknown response',
      customer: customer,
    );
  }
}
