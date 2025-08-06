class ApiResponse<T> {
  final bool isSuccess;
  final T? model;
  final String message;
  final int? statusCode;

  ApiResponse._({
    required this.isSuccess,
    this.model,
    required this.message,
    this.statusCode,
  });

  factory ApiResponse.success({T? model, String message = 'Success'}) {
    return ApiResponse._(isSuccess: true, model: model, message: message);
  }

  factory ApiResponse.error({required String message, int? statusCode}) {
    return ApiResponse._(
      isSuccess: false,
      message: message,
      statusCode: statusCode,
    );
  }
}
