import 'package:cr_assist/core/common/input_text_field.dart';
import 'package:cr_assist/features/auth/presentation/views/registration_screen/controller/registration_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class UPasswordFieldRegistration extends StatelessWidget {
  const UPasswordFieldRegistration({
    super.key,
    required RegistrationController registrationController,
  }) : _registrationController = registrationController;

  final RegistrationController _registrationController;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return UTextField(
        obscureText: _registrationController.isObscureText.value,
        validator: _registrationController.passwordValidate,
        controller: _registrationController.passwordController,
        labelText: "Password",
        prefixIcon: Icon(LucideIcons.lock),
        suffixIcon: IconButton(
          onPressed: () {
            _registrationController.passwordToggle();
          },
          icon: Icon(
            _registrationController.isObscureText.value
                ? LucideIcons.eyeClosed
                : LucideIcons.eye,
          ),
        ),
      );
    });
  }
}