import 'package:cr_assist/core/constants/colors.dart';
import 'package:cr_assist/core/common/app_feedback.dart';
import 'package:cr_assist/core/extensions/context_extension.dart';
import 'package:cr_assist/core/routes/app_router.dart';
import 'package:cr_assist/core/utils/constant.dart';
import 'package:cr_assist/features/auth/presentation/views/registration_screen/controller/registration_controller.dart';
import 'package:cr_assist/features/auth/presentation/views/registration_screen/widgets/cr_registration_checkbox.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  late final RegistrationController _controller;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controller = Get.put(RegistrationController());
  }

  @override
  void dispose() {
    Get.delete<RegistrationController>();
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
          icon: const Icon(Iconsax.arrow_left_2, color: Colors.white),
          onPressed: () => AppRouter.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Mini Logo
                Row(
                  children: [
                    CircleAvatar(
                      radius: 25.r,
                      backgroundColor: UColors.primary,
                      child: CircleAvatar(
                        radius: 22.r,
                        backgroundImage: AssetImage(Constants.appLogo),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      Constants.appName,
                      style: TextStyle(
                        color: context.isDark ? Colors.white : UColors.textDark,
                        fontSize: 18.spMin,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),
                
                Text(
                  "Create Account",
                  style: TextStyle(
                    color: context.isDark ? UColors.textPrimary : UColors.textDark,
                    fontSize: 28.spMin,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Join your batch and start collaborating",
                  style: TextStyle(
                    color: context.isDark ? UColors.textSecondary : UColors.darkGrey,
                    fontSize: 14.spMin,
                  ),
                ),
                SizedBox(height: 32.h),

                _buildField("Full Name", Iconsax.user, _controller.usernameController, _controller.usernameValidate),
                SizedBox(height: 16.h),

                _buildField("University Name", Iconsax.teacher, _controller.universityNameController, _controller.universityValidate),
                SizedBox(height: 16.h),

                Row(
                  children: [
                    Expanded(child: _buildField("Dept.", Iconsax.hierarchy, _controller.deptNameController, _controller.deptValidate)),
                    SizedBox(width: 12.w),
                    Expanded(child: _buildField("Batch", Iconsax.profile_2user, _controller.batchNameController, _controller.batchValidate)),
                  ],
                ),
                SizedBox(height: 16.h),

                _buildField("Email Address", Iconsax.sms, _controller.emailController, _controller.emailValidate),
                SizedBox(height: 16.h),

                Obx(() => _buildField(
                  "Password", 
                  Iconsax.lock, 
                  _controller.passwordController, 
                  _controller.passwordValidate,
                  isPassword: true,
                  obscureText: _controller.isObscureText.value,
                  onSuffixTap: _controller.passwordToggle,
                )),
                SizedBox(height: 24.h),

                Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: context.isDark ? UColors.containerDark : UColors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const CrRegistrationCheckbox(),
                ),
                SizedBox(height: 32.h),

                Obx(() => SizedBox(
                  width: double.infinity,
                  height: 56.h,
                  child: ElevatedButton(
                    onPressed: _controller.isLoading.value ? null : () async {
                      if (_formKey.currentState!.validate()) {
                        final bool isCR = Get.find<RegiCheckBoxController>().isSelected.value;
                        if (isCR) {
                          final success = await _controller.register();
                          if (success) AppRouter.go('/main');
                          if (!success && context.mounted && _controller.errorMessage.value.isNotEmpty) {
                            AppFeedback.showError(context, message: _controller.errorMessage.value);
                          }
                        } else {
                          AppRouter.push('/class-code');
                        }
                      }
                    },

                    child: _controller.isLoading.value 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Sign Up", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                )),
                SizedBox(height: 24.h),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Already have an account?", style: TextStyle(color: context.isDark ? Colors.white70 : UColors.darkGrey)),
                    TextButton(
                      onPressed: () => AppRouter.pop(),
                      child: const Text("Login", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: UColors.primary)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(String hint, IconData icon, TextEditingController controller, String? Function(String?)? validator, {bool isPassword = false, bool obscureText = false, VoidCallback? onSuffixTap}) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      style: TextStyle(color: context.isDark ? Colors.white : UColors.textDark),
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: context.isDark ? UColors.textSecondary : UColors.darkGrey),
        prefixIcon: Icon(icon, color: UColors.primary, size: 20),
        suffixIcon: isPassword 
          ? IconButton(
              icon: Icon(obscureText ? Iconsax.eye_slash : Iconsax.eye, color: UColors.textSecondary, size: 20),
              onPressed: onSuffixTap,
            )
          : null,
        filled: true,
        fillColor: context.isDark ? UColors.containerDark : UColors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.transparent)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: UColors.primary, width: 1.5)),
      ),
    );
  }
}
