import 'package:cr_assist/core/common/app_feedback.dart';
import 'package:cr_assist/core/constants/colors.dart';
import 'package:cr_assist/core/extensions/context_extension.dart';
import 'package:cr_assist/core/routes/app_router.dart';
import 'package:cr_assist/features/auth/presentation/views/forgot_password/controller/forgot_password_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  late final ForgotPasswordController _controller;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controller = Get.put(ForgotPasswordController());
  }

  @override
  void dispose() {
    Get.delete<ForgotPasswordController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.isDark ? UColors.dark : UColors.light,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: AppRouter.pop,
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back',
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 24.h),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CircleAvatar(
                    radius: 42.r,
                    backgroundColor: UColors.primary.withValues(alpha: 0.14),
                    child: Icon(
                      Iconsax.lock_1,
                      color: UColors.primary,
                      size: 38.r,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Text(
                    'Forgot password?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: context.isDark
                          ? UColors.textPrimary
                          : UColors.textDark,
                      fontSize: 26.spMin,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Enter your registered email and we will send you a 6-digit OTP.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: context.isDark
                          ? UColors.textSecondary
                          : UColors.darkGrey,
                      fontSize: 14.spMin,
                    ),
                  ),
                  SizedBox(height: 32.h),
                  TextFormField(
                    controller: _controller.emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: _controller.validateEmail,
                    style: TextStyle(
                      color: context.isDark ? Colors.white : UColors.textDark,
                    ),
                    decoration: _inputDecoration(
                      context,
                      'Email Address',
                      Iconsax.sms,
                    ),
                  ),
                  SizedBox(height: 22.h),
                  Obx(
                    () => SizedBox(
                      height: 54.h,
                      child: ElevatedButton(
                        onPressed: _controller.isLoading.value
                            ? null
                            : _sendOtp,
                        child: _controller.isLoading.value
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Send OTP',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;
    final success = await _controller.sendOtp();
    if (!mounted) return;
    if (success) {
      AppRouter.push(
        '/reset-password',
        extra: _controller.emailController.text.trim(),
      );
    } else if (_controller.errorMessage.value.isNotEmpty) {
      AppFeedback.showError(context, message: _controller.errorMessage.value);
    }
  }

  InputDecoration _inputDecoration(
    BuildContext context,
    String hint,
    IconData icon,
  ) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: context.isDark ? UColors.textSecondary : UColors.darkGrey,
      ),
      prefixIcon: Icon(icon, color: UColors.primary, size: 20),
      filled: true,
      fillColor: context.isDark ? UColors.containerDark : UColors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: UColors.primary, width: 1.5),
      ),
    );
  }
}
