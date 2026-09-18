import 'package:cr_assist/features/onboarding/presentation/manager/controller/onboarding_controller.dart';
import 'package:cr_assist/features/onboarding/presentation/mobile_onboarding_page.dart';
import 'package:cr_assist/features/onboarding/presentation/tablet_onboarding_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(OnboardingController());
    return LayoutBuilder(
      builder: (context, constraints) {
        if (context.isTablet) {
          return TabletOnboardingPage();
        } else {
          return MobileOnboardingPage();
        }
      },
    );
  }
}