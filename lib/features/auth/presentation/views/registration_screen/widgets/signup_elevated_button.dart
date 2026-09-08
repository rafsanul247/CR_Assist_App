import 'package:cr_assist/core/routes/app_router.dart';
import 'package:cr_assist/core/common/elevated_button.dart';
import 'package:cr_assist/features/auth/presentation/views/registration_screen/controller/registration_controller.dart';
import 'package:cr_assist/features/auth/presentation/views/registration_screen/widgets/cr_registration_checkbox.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class USignUpButton extends StatelessWidget {
  const USignUpButton({super.key});

  @override
  Widget build(BuildContext context) {
    final RegistrationController controller = Get.find<RegistrationController>();

    return Obx(() {
      if (controller.isLoading.value) {
        return const CircularProgressIndicator();
      }

      return UElevatedButton(
        onPressed: () async {
          // Validate Form fields first
          if (!Form.of(context).validate()) return;

          final bool isCR = Get.find<RegiCheckBoxController>().isSelected.value;

          if (isCR) {
            // CR registers directly without class code
            final success = await controller.register();
            if (success) {
              AppRouter.go('/main');
            } else if (controller.errorMessage.value.isNotEmpty) {
              Get.snackbar("Error", controller.errorMessage.value);
            }
          } else {
            // Student flow: First go to Class Code screen
            AppRouter.push('/class-code');
          }
        },
        child: const Text("Sign Up"),
      );
    });
  }
}
