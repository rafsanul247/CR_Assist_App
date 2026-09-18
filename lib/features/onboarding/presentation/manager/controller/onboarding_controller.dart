import 'package:cr_assist/core/constants/texts.dart';
import 'package:cr_assist/core/routes/app_router.dart';
import 'package:cr_assist/core/services/fcm_and_local_messaging_service.dart';
import 'package:cr_assist/core/storage/storage_service.dart';
import 'package:cr_assist/core/utils/constant.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OnboardingController extends GetxController {
  static OnboardingController get instance => Get.find();

  // TODO: Add your observable variables here
  final pageController = PageController();
  var currentIndex = 0.obs;

  /// button text
  String get buttonText => switch (currentIndex.value) {
    1 => UTexts.ready,
    2 => UTexts.whatsNext,
    3 => UTexts.letsGo,
    _ => UTexts.textContinue, // ডিফল্ট বা ০ নাম্বার পেজের জন্য
  };

  // TODO: Add your methods here

  /// Update current Index when page scroll
  void updatePageIndicator(int index) {
    currentIndex.value = index;
  }

  ///Jump to specific dot selected page
  void dotNavigationClick(int index) {
    currentIndex.value = index;
    pageController.jumpToPage(index);
  }

  /// Update current index and jump to the next page
  Future<void> nextPage(BuildContext context) async {
    if (currentIndex.value == 2) {
      final status = await NotificationService().permissionStatus();
      if (status != AuthorizationStatus.authorized &&
          status != AuthorizationStatus.provisional) {
        if (!context.mounted) return;
        final shouldContinue = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Turn on notifications'),
            content: const Text(
              'Allow notifications to receive important class and notice updates.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('Continue Anyway'),
              ),
              FilledButton(
                onPressed: () async {
                  final permissionEnabled = await NotificationService()
                      .requestPermissionOrOpenSettings();
                  if (permissionEnabled && dialogContext.mounted) {
                    Navigator.of(dialogContext).pop(true);
                  }
                },
                child: const Text('Allow'),
              ),
            ],
          ),
        );

        if (shouldContinue == true) {
          _goToNextPage();
        }
        return;
      }
    }

    _goToNextPage();
  }

  void _goToNextPage() {
    if (currentIndex.value == 3) {
      currentIndex.value = 0; // Resetting manually before navigating
      _completeOnboarding();
      return;
    }
    currentIndex.value++;
    pageController.animateToPage(
      currentIndex.value,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  ///Skip page
  void skipPage() {
    currentIndex.value = 0; // Resetting manually before navigating
    _completeOnboarding();
  }

  Future<void> _completeOnboarding() async {
    await StorageService.set(Constants.keyOnboardingCompleted, true);
    AppRouter.go('/login');
  }

  @override
  void onClose() {
    pageController.dispose(); // Dispose the controller to prevent memory leaks
    currentIndex.value = 0; // Reset the index to 0 when leaving the page
    super.onClose();
  }
}
