import 'package:cr_assist/core/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class AppFeedback {
  AppFeedback._();

  static void showError(
    BuildContext context, {
    required String message,
    String title = 'Invalid information',
  }) {
    _show(context, message: message, title: title, color: UColors.error, icon: Iconsax.info_circle);
  }

  static void showSuccess(BuildContext context, {required String message, String title = 'Success'}) {
    _show(context, message: message, title: title, color: UColors.success, icon: Iconsax.tick_circle);
  }

  static void showInfo(BuildContext context, {required String message, String title = 'Info'}) {
    _show(context, message: message, title: title, color: UColors.primary, icon: Iconsax.info_circle);
  }

  static void _show(
    BuildContext context, {
    required String message,
    required String title,
    required Color color,
    required IconData icon,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          backgroundColor: UColors.containerDark,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: color.withValues(alpha: 0.45)),
          ),
          duration: const Duration(seconds: 4),
          content: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(message, style: const TextStyle(color: UColors.textSecondary, fontSize: 13)),
                  ],
                ),
              ),
              IconButton(
                onPressed: messenger.hideCurrentSnackBar,
                icon: const Icon(Icons.close, color: UColors.textSecondary, size: 18),
                tooltip: 'Dismiss',
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ),
      );
  }
}