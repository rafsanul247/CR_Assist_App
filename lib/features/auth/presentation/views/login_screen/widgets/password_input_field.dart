import 'package:cr_assist/core/common/input_text_field.dart';
import 'package:cr_assist/features/auth/presentation/views/login_screen/controller/login_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class UPasswordInputField extends StatelessWidget {
  const UPasswordInputField({
    super.key,
    required LoginController loginController,
  }) : _loginController = loginController;

  final LoginController _loginController;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return UTextField(
        controller: _loginController.passwordController,
        labelText: "Password",
        prefixIcon: Icon(LucideIcons.lock),
        validator: _loginController.validatePassword,
        obscureText: _loginController.isObscure.value,
        suffixIcon: IconButton(onPressed: () {
          _loginController.passwordSwitchToggle();
        }, icon: Icon(
            _loginController.isObscure.value ? LucideIcons.eyeClosed : LucideIcons.eye)),);
    });
  }
}