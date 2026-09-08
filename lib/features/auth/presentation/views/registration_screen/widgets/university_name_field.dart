import 'package:cr_assist/core/common/input_text_field.dart';
import 'package:cr_assist/features/auth/presentation/views/registration_screen/controller/registration_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UniversityNameField extends StatelessWidget {
  const UniversityNameField({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RegistrationController>();
    return UTextField(
      controller: controller.universityNameController,
      validator: controller.universityValidate,
      labelText: "University name",
      prefixIcon: const Icon(Icons.school_outlined),
    );
  }
}
