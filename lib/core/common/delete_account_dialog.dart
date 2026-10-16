import 'dart:ui';
import 'package:cr_assist/core/common/app_feedback.dart';
import 'package:cr_assist/core/constants/colors.dart';
import 'package:cr_assist/core/extensions/context_extension.dart';
import 'package:cr_assist/core/routes/app_router.dart';
import 'package:cr_assist/core/theme/widgets_theme/outlined_button_theme.dart';
import 'package:cr_assist/features/auth/presentation/manager/controller/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DeleteAccountDialog extends StatefulWidget {
  const DeleteAccountDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Delete Account',
      barrierColor: Colors.black.withValues(alpha: 0.6),
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, anim1, anim2) => const SizedBox(),
      transitionBuilder: (context, anim1, anim2, child) {
        return Transform.scale(
          scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack).value,
          child: Opacity(
            opacity: anim1.value,
            child: const DeleteAccountDialog(),
          ),
        );
      },
    );
  }

  @override
  State<DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<DeleteAccountDialog> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final bool isCR = authController.isCR;

    final String message = isCR
        ? "Warning: As a CR, deleting your account will permanently delete your entire batch and all associated classes, routines, resources, and student data."
        : "Are you sure you want to delete your account? This action cannot be undone.";

    return PopScope(
      canPop: !_isLoading,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(horizontal: 32),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: context.isDark ? UColors.containerDark : UColors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.12),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: UColors.error.withValues(alpha: 0.2),
                  blurRadius: 30,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Glowing Warning / Delete Icon Wrapper
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: UColors.error.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: UColors.error.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.delete_forever,
                    color: UColors.error,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                const Text(
                  "Delete Account?",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),

                // Description / Warning Message
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isCR ? UColors.error : UColors.textSecondary,
                    fontSize: 14,
                    height: 1.4,
                    fontWeight: isCR ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 28),

                // Action Buttons: Cancel and Delete
                Row(
                  children: [
                    // Cancel Button
                    Expanded(
                      child: OutlinedButton(
                        style: UOutlinedButtonTheme.radius12(context),
                        onPressed: _isLoading ? null : () => Navigator.pop(context),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Red Delete Button with Loading Indicator
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: UColors.error,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: _isLoading
                            ? null
                            : () async {
                                final navigator = Navigator.of(context, rootNavigator: true);
                                final messenger = ScaffoldMessenger.of(context);
                                setState(() => _isLoading = true);
                                final result = await authController.deleteAccount();

                                if (result.isRight()) {
                                  navigator.pop();
                                  AppFeedback.showSuccessWithMessenger(
                                    messenger,
                                    message: "Account deleted successfully.",
                                  );
                                  AppRouter.go('/login');
                                } else {
                                  if (mounted) {
                                    setState(() => _isLoading = false);
                                  }
                                  final failure =
                                      result.fold((l) => l, (r) => null);
                                  AppFeedback.showErrorWithMessenger(
                                    messenger,
                                    message: failure?.message ??
                                        "Failed to delete account. Please try again.",
                                  );
                                }
                              },
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                "Delete",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
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
}
