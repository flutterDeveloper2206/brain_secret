class CreateFranchiseResponse {
  const CreateFranchiseResponse({
    required this.statusCode,
    required this.message,
    this.data,
  });

  final int statusCode;
  final String message;
  final dynamic data;

  bool get isSuccess => statusCode == 200 || statusCode == 201;

  factory CreateFranchiseResponse.fromJson(Map<String, dynamic> json) {
    return CreateFranchiseResponse(
      statusCode: json['statusCode'] as int? ?? 0,
      message: json['message'] as String? ?? 'Unknown response',
      data: json['data'],
    );
  }
}
