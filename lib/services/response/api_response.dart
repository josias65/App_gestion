class ApiResponse<T> {
  final T? data;
  final String? message;
  final bool success;

  ApiResponse({
    this.data,
    this.message,
    required this.success,
  });

  factory ApiResponse.success(T data) {
    return ApiResponse(
      data: data,
      success: true,
    );
  }

  factory ApiResponse.error(String message) {
    return ApiResponse(
      message: message,
      success: false,
    );
  }

  bool get isSuccess => success;
  bool get hasError => !success;
  bool get hasData => data != null;
}
