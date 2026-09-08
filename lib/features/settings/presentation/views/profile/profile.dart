import 'package:cr_assist/core/common/logout_dialog.dart';
import 'package:cr_assist/core/constants/colors.dart';
import 'package:cr_assist/core/routes/app_router.dart';
import 'package:cr_assist/features/auth/presentation/manager/controller/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final user = authController.user.value;

    return Scaffold(
      backgroundColor: UColors.dark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left_2, color: Colors.white),
          onPressed: () => AppRouter.pop(),
        ),
        title: const Text(
          "My Profile",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          children: [
            SizedBox(height: 20.h),
            
            // ------------------ Profile Header ------------------
            Center(
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [UColors.primary, UColors.accent.withValues(alpha: 0.5)],
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 50.r,
                          backgroundColor: UColors.containerDark,
                          child: Icon(Iconsax.user, size: 40.r, color: UColors.primary),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: UColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Iconsax.camera, size: 14.r, color: Colors.white),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    user?.username ?? "No Name",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22.spMin,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    user?.email ?? "No Email",
                    style: TextStyle(
                      color: UColors.textSecondary,
                      fontSize: 14.spMin,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: UColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      user?.role ?? "STUDENT",
                      style: const TextStyle(
                        color: UColors.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 40.h),

            // ------------------ Details Cards ------------------
            _buildProfileItem(
              icon: Iconsax.teacher,
              label: "University",
              value: user?.universityName ?? "Not Set",
              accentColor: Colors.blue,
            ),
            _buildProfileItem(
              icon: Iconsax.hierarchy,
              label: "Department",
              value: user?.deptName ?? "Not Set",
              accentColor: Colors.purple,
            ),
            _buildProfileItem(
              icon: Iconsax.profile_2user,
              label: "Batch Info",
              value: user?.batchName ?? "Not Set",
              accentColor: Colors.orange,
            ),
            
            SizedBox(height: 32.h),
            
            // Logout Button (optional here too)
            SizedBox(
              width: double.infinity,
              height: 56.h,
              child: OutlinedButton.icon(
                onPressed: () {
                  LogoutDialog.show(context);
                },
                icon: const Icon(Iconsax.logout, size: 20),
                label: const Text("Logout from Account"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: UColors.error,
                  side: const BorderSide(color: UColors.error),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileItem({
    required IconData icon,
    required String label,
    required String value,
    required Color accentColor,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: UColors.containerDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: UColors.borderDark.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: accentColor, size: 22),
          ),
          SizedBox(width: 16.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: UColors.textSecondary,
                  fontSize: 12.spMin,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.spMin,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
