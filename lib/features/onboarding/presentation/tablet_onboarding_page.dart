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
// TABLET-SPECIFIC LANDSCAPE ORIENTATION ONBOARDING VIEW
// ============================================================================

class TabletOnboardingPage extends StatelessWidget {
  const TabletOnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    // LOCATE THE ALREADY INJECTED ONBOARDING CONTROLLER
    final controller = Get.find<OnboardingController>();

    return Scaffold(
      backgroundColor: context.isDark ? UColors.dark : UColors.light,
      body: SafeArea(
        child: Row(
          children: [

            // ── LEFT SIDE PANEL: PRODUCT ILLUSTRATIONS (60% VIEWPORT WIDTH) ──
            Expanded(
              flex: 6,
              child: Container(
                color: context.isDark ? UColors.darkerGrey.withValues(alpha: 0.2) : UColors.lightGrey,
                child: PageView(
                  controller: controller.pageController,
                  onPageChanged: controller.updatePageIndicator,
                  physics: const BouncingScrollPhysics(),
                  children: const [
                    _TabletImageItem(index: 0),
                    _TabletImageItem(index: 1),
                    _TabletImageItem(index: 2),
                    _TabletImageItem(index: 3),
                  ],
                ),
              ),
            ),

            // ── RIGHT SIDE PANEL: CONTROLS & CONTENT TRADEOFF (40% VIEWPORT WIDTH) ──
            Expanded(
              flex: 4,
              child: Container(
                decoration: BoxDecoration(
                  color: context.isDark ? UColors.dark : UColors.light,
                  border: Border(
                    left: BorderSide(
                      color: context.isDark ? UColors.darkerGrey : UColors.borderPrimary,
                      width: 0.5,
                    ),
                  ),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: 32.w,
                  vertical: 24.h,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ── SKIP ACTION INTERACTION CONTROLLER ──
                    Align(
                      alignment: Alignment.topRight,
                      child: TextButton(
                        onPressed: () => controller.skipPage(),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(50, 30),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          UTexts.skip,
                          style: context.tt.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: context.isDark ? UColors.light : UColors.black,
                            decoration: TextDecoration.underline,
                            decorationColor: context.isDark ? UColors.lightGrey : UColors.textDark,
                          ),
                        ),
                      ),
                    ),

                    const Spacer(),

                    // ── REACTIVE CONTENT LAYER WITH SMOOTH TRANSITION MATRIX ──
                    Obx(() {
                      final i = controller.currentIndex.value;

                      final titles = [
                        UTexts.onboardingScreenTitle1,
                        UTexts.onboardingScreenTitle2,
                        UTexts.onboardingScreenTitle3,
                        UTexts.onboardingScreenTitle4,
                      ];

                      final subtitles = [
                        UTexts.onboardingScreenSubTitle1,
                        UTexts.onboardingScreenSubTitle2,
                        UTexts.onboardingScreenSubTitle3,
                        UTexts.onboardingScreenSubTitle4,
                      ];

                      return AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        switchInCurve: Curves.easeIn,
                        switchOutCurve: Curves.easeOut,
                        child: Column(
                          key: ValueKey<int>(i),
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              titles[i],
                              style: context.tt.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: context.isDark ? UColors.textWhite : UColors.textDark,
                              ),
                            ),
                            SizedBox(height: USizes.spaceBtwItems.h),
                            Text(
                              subtitles[i],
                              style: context.tt.bodyMedium?.copyWith(
                                color: context.isDark
                                    ? UColors.textWhite.withValues(alpha: 0.6)
                                    : UColors.textDark.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),

                    const Spacer(),

                    // ── DYNAMIC PAGE TRACK INDICATOR ──
                    Center(
                      child: SmoothPageIndicator(
                        controller: controller.pageController,
                        onDotClicked: controller.dotNavigationClick,
                        count: 4,
                        effect: ExpandingDotsEffect(
                          dotHeight: 7.r,
                          dotWidth: 7.r,
                          spacing: 6.r,
                          activeDotColor: UColors.primary,
                          dotColor: context.isDark ? UColors.darkGrey : UColors.grey,
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),

                    // ── CORE ACTION EXECUTION SYSTEM ──
                    SizedBox(
                      width: double.infinity,
                      height: 54.h,
                      child: UElevatedButton(
                        onPressed: () => controller.nextPage(),
                        child: Obx(
                              () => Text(
                            controller.buttonText,
                            style: context.tt.titleMedium?.copyWith(
                              color: UColors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// PRIVATE ATOM WIDGET: TABLET ILLUSTRATION INTERFACES
// ============================================================================

class _TabletImageItem extends StatelessWidget {
  final int index;
  const _TabletImageItem({required this.index});

  static const _images = [
    'assets/images/onboarding_one.png',
    'assets/images/onboarding_two.png',
    'assets/images/onboarding_three.png',
    'assets/images/onboarding_four.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(40.r),
        child: Image.asset(
          _images[index],
          height: 380.h,
          width: 380.w,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}