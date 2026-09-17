class PasswordResetResponse {
  final String message;

  const PasswordResetResponse({required this.message});

  factory PasswordResetResponse.fromJson(Map<String, dynamic> json) {
    return PasswordResetResponse(
      message: json['message'] as String? ?? 'Request completed successfully.',
    );
  }
}
