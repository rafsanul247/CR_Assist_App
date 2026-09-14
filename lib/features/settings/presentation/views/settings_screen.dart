import 'package:cr_assist/core/common/logout_dialog.dart';
import 'package:cr_assist/core/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

// Data Model
class SettingsItemModel {
  final String title;
  final String? subtitle;
  final IconData icon;
  final String? route;
  final VoidCallback? onTap;
  final bool isDestructive;

  const SettingsItemModel({
    required this.title,
    required this.icon,
    this.subtitle,
    this.route,
    this.onTap,
    this.isDestructive = false,
  });
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UColors.dark,
      appBar: AppBar(
        title: const Text(
          "Settings",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          children: [
            const _UserProfileCard(),
            const SizedBox(height: 24),
            _SettingsGroup(
              title: "Account & Preferences",
              items: [
                const SettingsItemModel(
                  title: "Profile",
                  subtitle: "See Batch details",
                  icon: Iconsax.user,
                  route: '/profile',
                ),
                const SettingsItemModel(
                  title: "Notifications",
                  subtitle: "Reminders and class alerts",
                  icon: Iconsax.notification,
                  route: '/notice',
                ),
                const SettingsItemModel(
                  title: "Class & Semester",
                  subtitle: "Your Semesters",
                  icon: Iconsax.teacher,
                  route: '/main',
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SettingsGroup(
              title: "System & Info",
              items: [
                const SettingsItemModel(
                  title: "About CR Assistant",
                  subtitle: "App version and release notes",
                  icon: Iconsax.info_circle,
                  route: '/about',
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SettingsGroup(
              title: "Session",
              items: [
                SettingsItemModel(
                  title: "Log Out",
                  subtitle: "Sign out",
                  icon: Iconsax.logout,
                  isDestructive: true,
                  onTap: () => LogoutDialog.show(context),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

}

class _UserProfileCard extends StatelessWidget {
  const _UserProfileCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: UColors.primary.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: UColors.borderDark.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: UColors.primary.withValues(alpha: 0.9),
            child: const Icon(
              Iconsax.user,
              size: 32,
              color: UColors.white,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Student Profile",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  "Class Representative Assistant",
                  style: TextStyle(
                    color: UColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  final String title;
  final List<SettingsItemModel> items;

  const _SettingsGroup({
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: UColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 11,
              letterSpacing: 1.1,
            ),
          ),
        ),
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: UColors.containerDark,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: UColors.borderDark.withValues(alpha: 0.5),
            ),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              indent: 56,
              color: UColors.borderDark.withValues(alpha: 0.3),
            ),
            itemBuilder: (context, index) {
              return _SettingsTile(item: items[index]);
            },
          ),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final SettingsItemModel item;

  const _SettingsTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final activeColor = item.isDestructive
        ? UColors.error
        : Colors.white;


    final iconColor = item.isDestructive
        ? UColors.error
        : UColors.primary;

    return Material(
      color: Colors.transparent,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: UColors.dark.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(item.icon, color: iconColor, size: 22),
        ),
        title: Text(
          item.title,
          style: TextStyle(
            color: activeColor,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        subtitle: item.subtitle != null
            ? Text(
          item.subtitle!,
          style: const TextStyle(
            color: UColors.textSecondary,
            fontSize: 12,
          ),
        )
            : null,
        trailing: const Icon(
          Iconsax.arrow_right_2,
          size: 18,
          color: UColors.textSecondary,
        ),
        onTap: () {
          if (item.onTap != null) {
            item.onTap!();
          } else if (item.route != null) {
            context.push(item.route!);
          }
        },
      ),
    );
  }
}
