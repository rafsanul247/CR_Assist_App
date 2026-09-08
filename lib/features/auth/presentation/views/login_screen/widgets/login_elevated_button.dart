import 'package:cr_assist/core/common/elevated_button.dart';
import 'package:cr_assist/core/routes/app_router.dart';
import 'package:cr_assist/core/constants/texts.dart';
import 'package:cr_assist/features/auth/presentation/views/login_screen/controller/login_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginElevatedButton extends StatelessWidget {
  const LoginElevatedButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Already put() in LoginScreen — find() reuses that same instance,
    // doesn't create a new one.
    final LoginController controller = Get.find<LoginController>();

    return Obx(() {
      if (controller.isLoading.value) {
        return const CircularProgressIndicator();
      }

      return UElevatedButton(
        onPressed: () async {
          // Form.of(context) finds the nearest Form ancestor — this widget
          // itself doesn't hold the _formKey, but it's built inside the
          // same Form, so this works without passing the key down.
          if (!Form.of(context).validate()) return;

          final success = await controller.login();

          if (success && context.mounted) {
            AppRouter.go('/main');
          } else if (context.mounted && controller.errorMessage.value.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(controller.errorMessage.value)),
            );
          }
        },
        child: Text(UTexts.login),
      );
    });
  }
}