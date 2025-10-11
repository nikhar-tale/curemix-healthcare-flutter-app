class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final String? error;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.error,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      message: json['message']?.toString() ?? '',
      data: json['data'] != null && fromJsonT != null 
          ? fromJsonT(json['data']) 
          : null,
      error: json['error']?.toString(),
    );
  }

  // Success response
  factory ApiResponse.success({
    required String message,
    T? data,
  }) {
    return ApiResponse<T>(
      success: true,
      message: message,
      data: data,
    );
  }

  // Error response
  factory ApiResponse.error({
    required String message,
    String? error,
  }) {
    return ApiResponse<T>(
      success: false,
      message: message,
      error: error,
    );
  }
}