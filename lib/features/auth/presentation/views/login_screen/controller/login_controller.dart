import 'package:cr_assist/features/auth/presentation/manager/controller/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cr_assist/injection.dart';
import 'package:cr_assist/features/auth/domain/usecases/auth_usecase.dart';

class LoginController extends GetxController {
  final AuthUseCase _authUseCase = sl<AuthUseCase>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  var isObscure = true.obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    clearFields(); // Ensure fields are empty on start
  }

  void clearFields() {
    emailController.clear();
    passwordController.clear();
    errorMessage.value = '';
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return "Email cannot be empty!";
    if (!GetUtils.isEmail(value)) return "Enter a valid email address";
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return "Please enter your password!";
    if (value.length < 6) return "Password must be at least 6 characters long";
    return null;
  }

  void passwordSwitchToggle() => isObscure.value = !isObscure.value;

  Future<bool> login() async {
    isLoading.value = true;
    errorMessage.value = '';

    final result = await _authUseCase.login(
      email: emailController.text.trim(),
      password: passwordController.text,
    );

    bool success = false;
    result.fold(
      (failure) => errorMessage.value = failure.message,
      (user) {
        if (sl.isRegistered<AuthController>()) {
          sl<AuthController>().user.value = user;
        }
        success = true;
      },
    );

    isLoading.value = false;
    return success;
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
