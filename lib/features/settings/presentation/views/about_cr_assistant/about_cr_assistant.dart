import 'package:cr_assist/core/constants/colors.dart';
import 'package:cr_assist/core/extensions/context_extension.dart';
import 'package:cr_assist/core/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutCrAssistant extends StatelessWidget {
  const AboutCrAssistant({super.key});

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Iconsax.arrow_left_2, color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => AppRouter.pop(),
        ),
        title: Text(
          'About Developer',
          style: context.tt.titleLarge,
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            SizedBox(height: 20.h),
            
            // ------------------ Profile Header ------------------
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 120.r,
                    height: 120.r,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: UColors.primary.withValues(alpha: 0.2), width: 2),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [UColors.primary, UColors.accent.withValues(alpha: 0.5)],
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 52.r,
                      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                      child: CircleAvatar(
                        radius: 48.r,
                        backgroundImage: const AssetImage("assets/images/rafsan_profile.jpg"),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            
            Text(
              'Rafsanul Rifat',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 24.spMin,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(height: 6.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: UColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: UColors.primary.withValues(alpha: 0.2)),
              ),
              child: Text(
                'Full-Stack Developer',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            
            SizedBox(height: 32.h),

            // ------------------ Social Connect ------------------
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _SocialBtn(icon: Iconsax.global, color: Colors.cyan, onTap: () => _launchUrl('https://rafsanulrifat.vercel.app/')),
                  _SocialBtn(icon: Iconsax.code, color: Colors.white, onTap: () => _launchUrl('https://github.com/rafsanul247')),
                  _SocialBtn(icon: Iconsax.briefcase, color: Colors.blueAccent, onTap: () => _launchUrl('https://www.linkedin.com/in/rafsanulrifatcse47')),
                  _SocialBtn(icon: Iconsax.facebook, color: const Color(0xFF1877F2), onTap: () => _launchUrl('https://www.facebook.com/rafsanul.rifat.47')),
                ],
              ),
            ),
            
            SizedBox(height: 32.h),

            // ------------------ Information Cards ------------------
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                children: [
                  _ModernInfoCard(
                    icon: Iconsax.teacher,
                    label: 'University',
                    value: 'Dhaka International Univ.',
                  ),
                  SizedBox(height: 12.h),
                  _ModernInfoCard(
                    icon: Iconsax.code_1,
                    label: 'Department',
                    value: 'CSE',
                  ),
                  SizedBox(height: 12.h),
                  _ModernInfoCard(
                    icon: Iconsax.security_safe,
                    label: 'Interested in',
                    value: 'Cybersecurity',
                  ),
                  
                  SizedBox(height: 24.h),
                  
                  _BioSection(
                    title: 'About the Developer',
                    content: 'I build full-stack web and mobile applications with a focus on seamless UX and robust logic. Currently pursuing CS while diving deeper into cybersecurity to build safer digital products.',
                    accentColor: UColors.primary,
                  ),
                  
                  SizedBox(height: 16.h),
                  
                  _BioSection(
                    title: 'About CR Assistant',
                    content: 'CR Assistant is an all-in-one platform built to streamline academic resource management. CRs can seamlessly push notices, notes, and PDFs while students get instantaneous support via an AI assistant.',
                    accentColor: UColors.accent,
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 40.h),
            
            Text(
              'CR Assistant • v1.0.0',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                fontSize: 12,
                letterSpacing: 1,
              ),
            ),
            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }
}

class _SocialBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _SocialBtn({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: UColors.borderDark),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
    );
  }
}

class _ModernInfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ModernInfoCard({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: UColors.borderDark.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: UColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: UColors.primary, size: 20),
          ),
          SizedBox(width: 16.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: context.tt.bodySmall?.copyWith(fontSize: 12.spMin)),
              Text(value, style: context.tt.titleMedium?.copyWith(fontSize: 14.spMin)),
            ],
          ),
        ],
      ),
    );
  }
}

class _BioSection extends StatelessWidget {
  final String title;
  final String content;
  final Color accentColor;

  const _BioSection({required this.title, required this.content, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: UColors.borderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(width: 10.w),
              Text(
                title,
                style: context.tt.titleMedium?.copyWith(fontSize: 16.spMin),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            content,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 13.spMin,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
