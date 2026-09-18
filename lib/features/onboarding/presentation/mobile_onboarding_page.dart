import 'package:cr_assist/core/common/elevated_button.dart';
import 'package:cr_assist/core/constants/colors.dart';
import 'package:cr_assist/core/constants/sizes.dart';
import 'package:cr_assist/core/constants/texts.dart';
import 'package:cr_assist/features/onboarding/presentation/manager/controller/onboarding_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../core/extensions/context_extension.dart';

// ============================================================================
// MOBILE-SPECIFIC ONBOARDING SCALABLE VIEW
// ============================================================================

class MobileOnboardingPage extends StatelessWidget {
  const MobileOnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    // INITIALIZE AND INJECT CORE BUSINESS CONTROLLER
    final controller = Get.put(OnboardingController());

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.all(USizes.md),
          child: Column(
            children: [
              // ── TOP UTILITY ROW: SKIP ACTION ──
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () => controller.skipPage(),
                  child: Text(
                    UTexts.skip,
                    style: context.tt.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: context.isDark ? UColors.light : UColors.black,
                      decoration: TextDecoration.underline,
                      decorationColor: context.isDark
                          ? UColors.lightGrey
                          : UColors.textDark,
                    ),
                  ),
                ),
              ),
              20.verticalSpace,

              // ── RESPONSIVE MAIN SLIDER LAYER ──
              SizedBox(
                height: 480.h,
                child: PageView(
                  controller: controller.pageController,
                  onPageChanged: controller.updatePageIndicator,
                  physics: const ClampingScrollPhysics(),
                  children: [
                    OnboardingPageView(
                      image: 'assets/images/onboarding_one.png',
                      title: UTexts.onboardingScreenTitle1,
                      subtitle: UTexts.onboardingScreenSubTitle1,
                    ),
                    OnboardingPageView(
                      image: 'assets/images/onboarding_two.png',
                      title: UTexts.onboardingScreenTitle2,
                      subtitle: UTexts.onboardingScreenSubTitle2,
                    ),
                    OnboardingPageView(
                      image: 'assets/images/onboarding_three.png',
                      title: UTexts.onboardingScreenTitle3,
                      subtitle: UTexts.onboardingScreenSubTitle3,
                    ),
                    OnboardingPageView(
                      image: 'assets/images/onboarding_four.png',
                      title: UTexts.onboardingScreenTitle4,
                      subtitle: UTexts.onboardingScreenSubTitle4,
                    ),
                  ],
                ),
              ),
              16.verticalSpace,

              // ── NAVIGATION TRACK INDICATOR ──
              SmoothPageIndicator(
                controller: controller.pageController,
                onDotClicked: controller.dotNavigationClick,
                count: 4,
                effect: ExpandingDotsEffect(
                  dotHeight: 6.h,
                  dotWidth: 6.w,
                  activeDotColor: UColors.primary,
                  dotColor: context.isDark ? UColors.darkerGrey : UColors.grey,
                ),
              ),
              40.verticalSpace,

              // ── REUSABLE ACTION SYSTEM ──
              UElevatedButton(
                onPressed: () => controller.nextPage(context),
                child: Obx(
                  () => Text(
                    controller.buttonText,
                    style: context.tt.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: UColors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// CELL LAYOUT: INDIVIDUAL SLIDE CONTENT SCALER
// ============================================================================

class OnboardingPageView extends StatelessWidget {
  const OnboardingPageView({
    super.key,
    required this.image,
    required this.title,
    required this.subtitle,
  });

  final String image;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── SCALE-SAFE ILLUSTRATION ASSET ──
          Image.asset(image, height: 270.h, width: 270.w, fit: BoxFit.contain),
          SizedBox(height: USizes.spaceBtwSections),

          // ── ACCESSIBILITY TYPOGRAPHY TITLE TOKEN ──
          Text(
            title,
            textAlign: TextAlign.center,
            style: context.tt.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: context.isDark ? UColors.textWhite : UColors.textDark,
            ),
          ),
          SizedBox(height: USizes.spaceBtwItems),

          // ── ACCESSIBILITY TYPOGRAPHY DESCRIPTION TOKEN ──
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: context.tt.bodyMedium?.copyWith(
              color: context.isDark
                  ? UColors.textWhite.withValues(alpha: 0.7)
                  : UColors.textDark.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
