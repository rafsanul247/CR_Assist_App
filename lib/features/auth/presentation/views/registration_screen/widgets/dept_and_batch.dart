import 'package:cr_assist/core/common/input_text_field.dart';
import 'package:cr_assist/features/auth/presentation/views/registration_screen/controller/registration_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class DeptAndBatch extends StatelessWidget {
  const DeptAndBatch({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RegistrationController>();
    return Row(
      children: [
        // Dept.
        Expanded(
          child: UTextField(
            controller: controller.deptNameController,
            validator: controller.deptValidate,
            labelText: "Dept.",
            prefixIcon: const Icon(Icons.school_outlined),
          ),
        ),

        10.horizontalSpace,

        // Batch
        Expanded(
          child: UTextField(
            controller: controller.batchNameController,
            validator: controller.batchValidate,
            labelText: "Batch",
            prefixIcon: const Icon(Icons.school_outlined),
          ),
        ),
      ],
    );
  }
}
