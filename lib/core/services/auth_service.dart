import 'package:cr_assist/core/error/exception_handler.dart';
import 'package:cr_assist/core/models/password_reset_response.dart';
import 'package:cr_assist/core/network/dio_client.dart';
import 'package:cr_assist/core/utils/api_endpoint.dart';

class AuthService {
  final DioClient dioClient;

  AuthService({required this.dioClient});

  Future<PasswordResetResponse> sendPasswordResetOtp({
    required String email,
  }) async {
    try {
      final response = await dioClient.post(
        ApiEndpoint.forgotPassword,
        data: {'email': email},
      );
      if (response.statusCode != 200) {
        throw ServerException(
          'Unable to send password reset OTP.',
          statusCode: response.statusCode,
        );
      }
      return PasswordResetResponse.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } catch (error) {
      throw ExceptionHandler.handleException(error);
    }
  }

  Future<PasswordResetResponse> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      final response = await dioClient.post(
        ApiEndpoint.resetPassword,
        data: {'email': email, 'otp': otp, 'newPassword': newPassword},
      );
      if (response.statusCode != 200) {
        throw ServerException(
          'Password reset failed.',
          statusCode: response.statusCode,
        );
      }
      return PasswordResetResponse.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } catch (error) {
      throw ExceptionHandler.handleException(error);
    }
  }
}
