import 'package:cr_assist/core/common/input_text_field.dart';
import 'package:cr_assist/features/auth/presentation/views/registration_screen/controller/registration_controller.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class UEmailFieldRegistration extends StatelessWidget {
  const UEmailFieldRegistration({
    super.key,
    required RegistrationController registrationController,
  }) : _registrationController = registrationController;

  final RegistrationController _registrationController;

  @override
  Widget build(BuildContext context) {
    return UTextField(
      validator: _registrationController.emailValidate,
      controller: _registrationController.emailController,
      labelText: "Email",
      prefixIcon: Icon(LucideIcons.mail),
    );
  }
}