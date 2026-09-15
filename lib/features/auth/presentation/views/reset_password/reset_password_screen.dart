import 'package:cr_assist/core/common/app_feedback.dart';
import 'package:cr_assist/core/constants/colors.dart';
import 'package:cr_assist/core/extensions/context_extension.dart';
import 'package:cr_assist/core/routes/app_router.dart';
import 'package:cr_assist/features/auth/presentation/views/reset_password/controller/reset_password_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:pinput/pinput.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;

  const ResetPasswordScreen({super.key, required this.email});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  late final ResetPasswordController _controller;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controller = Get.put(ResetPasswordController(email: widget.email));
  }

  @override
  void dispose() {
    Get.delete<ResetPasswordController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pinTheme = PinTheme(
      width: 48.w,
      height: 54.h,
      textStyle: TextStyle(
        color: context.isDark ? Colors.white : UColors.textDark,
        fontSize: 20.spMin,
        fontWeight: FontWeight.w700,
      ),
      decoration: BoxDecoration(
        color: context.isDark ? UColors.containerDark : UColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.transparent),
      ),
    );

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
                  Icon(Iconsax.shield_tick, color: UColors.primary, size: 58.r),
                  SizedBox(height: 20.h),
                  Text(
                    'Reset password',
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
                    'Enter the OTP sent to ${widget.email}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: context.isDark
                          ? UColors.textSecondary
                          : UColors.darkGrey,
                      fontSize: 14.spMin,
                    ),
                  ),
                  SizedBox(height: 28.h),
                  Pinput(
                    controller: _controller.otpController,
                    length: 6,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    autofocus: true,
                    pinAnimationType: PinAnimationType.fade,
                    defaultPinTheme: pinTheme,
                    focusedPinTheme: pinTheme.copyWith(
                      decoration: pinTheme.decoration!.copyWith(
                        border: Border.all(color: UColors.primary, width: 1.5),
                      ),
                    ),
                    errorPinTheme: pinTheme.copyWith(
                      decoration: pinTheme.decoration!.copyWith(
                        border: Border.all(color: UColors.error),
                      ),
                    ),
                    validator: _controller.validateOtp,
                  ),
                  SizedBox(height: 24.h),
                  Obx(
                    () => _passwordField(
                      context,
                      controller: _controller.newPasswordController,
                      hint: 'New password',
                      obscureText: _controller.isNewPasswordObscure.value,
                      onToggle: () => _controller.isNewPasswordObscure.toggle(),
                      validator: _controller.validatePassword,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Obx(
                    () => _passwordField(
                      context,
                      controller: _controller.confirmPasswordController,
                      hint: 'Confirm password',
                      obscureText: _controller.isConfirmPasswordObscure.value,
                      onToggle: () =>
                          _controller.isConfirmPasswordObscure.toggle(),
                      validator: _controller.validateConfirmPassword,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Obx(
                    () => SizedBox(
                      height: 54.h,
                      child: ElevatedButton(
                        onPressed: _controller.isLoading.value
                            ? null
                            : _resetPassword,
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
                                'Reset Password',
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

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;
    final success = await _controller.resetPassword();
    if (!mounted) return;
    if (success) {
      AppRouter.go('/login?reset=success');
    } else if (_controller.errorMessage.value.isNotEmpty) {
      AppFeedback.showError(context, message: _controller.errorMessage.value);
    }
  }

  Widget _passwordField(
    BuildContext context, {
    required TextEditingController controller,
    required String hint,
    required bool obscureText,
    required VoidCallback onToggle,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      style: TextStyle(color: context.isDark ? Colors.white : UColors.textDark),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: context.isDark ? UColors.textSecondary : UColors.darkGrey,
        ),
        prefixIcon: const Icon(Iconsax.lock, color: UColors.primary, size: 20),
        suffixIcon: IconButton(
          onPressed: onToggle,
          icon: Icon(
            obscureText ? Iconsax.eye_slash : Iconsax.eye,
            color: UColors.textSecondary,
            size: 20,
          ),
        ),
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
      ),
    );
  }
}
