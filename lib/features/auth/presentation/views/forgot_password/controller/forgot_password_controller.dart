import 'package:cr_assist/core/error/exception_handler.dart';
import 'package:cr_assist/core/services/auth_service.dart';
import 'package:cr_assist/injection.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgotPasswordController extends GetxController {
  final AuthService _authService = sl<AuthService>();
  final emailController = TextEditingController();
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email cannot be empty.';
    if (!GetUtils.isEmail(value.trim())) return 'Enter a valid email address.';
    return null;
  }

  Future<bool> sendOtp() async {
    if (isLoading.value) return false;

    isLoading.value = true;
    errorMessage.value = '';
    try {
      await _authService.sendPasswordResetOtp(
        email: emailController.text.trim(),
      );
      return true;
    } catch (error) {
      errorMessage.value = _friendlyMessage(error);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  String _friendlyMessage(Object error) {
    if (error is NetworkException) {
      return 'Network connection problem. Please try again.';
    }
    if (error is TimeoutException) {
      return 'The request timed out. Please try again.';
    }
    if (error is ServerException) {
      switch (error.statusCode) {
        case 404:
          return 'No account found with this email address.';
        case 503:
          return 'Unable to send password reset OTP. Please try again later.';
        case 500:
          return 'Password reset service is not ready. Please try again later.';
        case 400:
          return error.message;
      }
      return error.message;
    }
    return 'Unable to send OTP. Please try again.';
  }

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }
}
