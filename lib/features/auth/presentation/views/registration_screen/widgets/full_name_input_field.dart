import 'package:cr_assist/core/common/input_text_field.dart';
import 'package:cr_assist/features/auth/presentation/views/registration_screen/controller/registration_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class UFullNameField extends StatelessWidget {
  const UFullNameField({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RegistrationController>();
    return UTextField(
      controller: controller.usernameController,
      validator: controller.usernameValidate,
      labelText: "Full Name",
      prefixIcon: const Icon(LucideIcons.user),
    );
  }
}
