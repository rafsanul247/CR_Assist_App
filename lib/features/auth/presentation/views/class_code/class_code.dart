import 'package:cr_assist/core/constants/colors.dart';
import 'package:cr_assist/core/common/app_feedback.dart';
import 'package:cr_assist/core/extensions/context_extension.dart';
import 'package:cr_assist/core/routes/app_router.dart';
import 'package:cr_assist/features/auth/presentation/views/registration_screen/controller/registration_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class ClassCode extends StatelessWidget {
  const ClassCode({super.key});

  @override
  Widget build(BuildContext context) {
    final RegistrationController controller = Get.find<RegistrationController>();

    return Scaffold(
      backgroundColor: context.isDark ? UColors.dark : UColors.light,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left_2, color: Colors.white),
          onPressed: () => AppRouter.pop(),
        ),
      ),
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.h),
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(color: UColors.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: const Icon(Iconsax.key, color: UColors.primary, size: 32),
              ),
              SizedBox(height: 24.h),
              Text("Enter Class Code", style: TextStyle(color: context.isDark ? UColors.textPrimary : UColors.textDark, fontSize: 26.spMin, fontWeight: FontWeight.bold)),
              SizedBox(height: 12.h),
              Text("Please enter the unique code provided by your CR to join your batch.", style: TextStyle(color: context.isDark ? UColors.textSecondary : UColors.darkGrey)),
              SizedBox(height: 40.h),
              
              TextField(
                controller: controller.classCodeController,
                autofocus: true,
                style: TextStyle(color: context.isDark ? Colors.white : UColors.textDark, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 8),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: "######",
                  hintStyle: TextStyle(color: UColors.textSecondary.withValues(alpha: 0.3)),
                  filled: true,
                  fillColor: context.isDark ? UColors.containerDark : UColors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: UColors.primary, width: 2),
                  ),
                ),
                onChanged: (_) => controller.errorMessage.value = '', // Clear error on change
              ),
              
              Obx(() => controller.errorMessage.isNotEmpty 
                ? Padding(
                    padding: EdgeInsets.only(top: 16.h),
                    child: Row(
                      children: [
                        const Icon(Iconsax.info_circle, color: UColors.error, size: 16),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            controller.errorMessage.value,
                            style: TextStyle(color: UColors.error, fontSize: 13.spMin),
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink()
              ),
              
              const Spacer(),
              Obx(() => controller.isLoading.value 
                ? const Center(child: CircularProgressIndicator(color: UColors.primary))
                : SizedBox(
                    width: double.infinity,
                    height: 56.h,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (controller.classCodeController.text.length < 4) {
                          controller.errorMessage.value = "Short Code";
                          AppFeedback.showError(context, message: 'Please enter a valid class code.', title: 'Wrong class code');
                          return;
                        }
                        final success = await controller.register();
                        if (success) {
                          AppRouter.go('/main');
                        } else if (context.mounted && controller.errorMessage.value.isNotEmpty) {
                          AppFeedback.showError(context, message: controller.errorMessage.value, title: 'Wrong class code');
                        }
                        // If failed, controller.errorMessage is already populated and UI will show it
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: UColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text("Join Batch & Sign Up", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  )
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}
