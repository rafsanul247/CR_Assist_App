import 'package:cr_assist/core/error/exception_handler.dart';
import 'package:cr_assist/core/services/auth_service.dart';
import 'package:cr_assist/injection.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ResetPasswordController extends GetxController {
  final AuthService _authService = sl<AuthService>();
  final String email;
  final otpController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final isLoading = false.obs;
  final isNewPasswordObscure = true.obs;
  final isConfirmPasswordObscure = true.obs;
  final errorMessage = ''.obs;

  ResetPasswordController({required this.email});

  String? validateOtp(String? value) {
    if (value == null || value.length != 6) return 'Enter the 6-digit OTP.';
    if (!RegExp(r'^\d{6}$').hasMatch(value)) {
      return 'OTP must contain digits only.';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password cannot be empty.';
    if (value.length < 6) return 'Password must be at least 6 characters.';
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return 'Confirm your password.';
    if (value != newPasswordController.text) return 'Passwords do not match.';
    return null;
  }

  Future<bool> resetPassword() async {
    if (isLoading.value) return false;

    isLoading.value = true;
    errorMessage.value = '';
    try {
      await _authService.resetPassword(
        email: email,
        otp: otpController.text.trim(),
        newPassword: newPasswordController.text,
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
      if (error.statusCode == 400) {
        return error.message.isNotEmpty
            ? error.message
            : 'Invalid or expired OTP or invalid password input.';
      }
      final message = error.message.toLowerCase();
      if (message.contains('otp') ||
          message.contains('expired') ||
          message.contains('invalid')) {
        return 'Invalid or expired OTP. Please request a new OTP.';
      }
      if (error.statusCode != null && error.statusCode! >= 500) {
        return 'Server error. Please try again later.';
      }
      return error.message;
    }
    return 'Unable to reset password. Please try again.';
  }

  @override
  void onClose() {
    otpController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
