import 'package:cr_assist/core/constants/colors.dart';
import 'package:cr_assist/features/notice/presentation/views/notice_screen.dart';
import 'package:cr_assist/features/semesters/presentation/views/semester_list_view/semester_list_view.dart';
import 'package:cr_assist/features/settings/presentation/views/settings_screen.dart';
import 'package:cr_assist/core/services/fcm_and_local_messaging_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;
  const MainScreen({super.key, this.initialIndex = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  late int _currentIndex;
  final NotificationService _notificationService = NotificationService();
  Future<AuthorizationStatus>? _permissionStatus;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _currentIndex = widget.initialIndex;
    _permissionStatus = _notificationService.permissionStatus();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      setState(() {
        _permissionStatus = _notificationService.permissionStatus();
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  final List<Widget> _screens = const [
    SemesterListView(),
    NoticeScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        top: true,
        bottom: false,
        child: Column(
          children: [
            FutureBuilder<AuthorizationStatus>(
              future: _permissionStatus,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SizedBox.shrink();
                }
                if (snapshot.data == AuthorizationStatus.authorized ||
                    snapshot.data == AuthorizationStatus.provisional) {
                  return const SizedBox.shrink();
                }
                return _NotificationBanner(
                  onTurnOn: () async {
                    await _notificationService
                        .requestPermissionOrOpenSettings();
                    if (mounted) {
                      setState(() {
                        _permissionStatus = _notificationService
                            .permissionStatus();
                      });
                    }
                  },
                );
              },
            ),
            Expanded(
              child: IndexedStack(index: _currentIndex, children: _screens),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Theme(
        // ১. এখানে স্প্ল্যাশ এবং আইকন প্রেসড ইফেক্ট পুরোপুরি বন্ধ করা হয়েছে
        data: Theme.of(context).copyWith(
          splashFactory: NoSplash.splashFactory, // আঙুলের ছোপ বা রিপল বন্ধ করবে
          highlightColor:
              Colors.transparent, // চেপে রাখলে হওয়া হাইলাইট বন্ধ করবে
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: BottomNavigationBar(
            backgroundColor: Theme.of(context).colorScheme.surface,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: UColors.navActive,
            unselectedItemColor: UColors.navInactive,
            currentIndex: _currentIndex,
            showUnselectedLabels: true,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            items: const [
              BottomNavigationBarItem(icon: Icon(Iconsax.home), label: 'Home'),
              BottomNavigationBarItem(
                icon: Icon(Iconsax.notification),
                label: 'Notice',
              ),
              BottomNavigationBarItem(
                icon: Icon(Iconsax.setting),
                label: "Settings",
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationBanner extends StatelessWidget {
  const _NotificationBanner({required this.onTurnOn});

  final VoidCallback onTurnOn;

  @override
  Widget build(BuildContext context) {
    return MaterialBanner(
      backgroundColor: Theme.of(context).colorScheme.errorContainer,
      content: Text(
        'Notifications are turned off. Turn them on to receive updates.',
        style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer),
      ),
      leading: Icon(
        Icons.notifications_off_outlined,
        color: Theme.of(context).colorScheme.onErrorContainer,
      ),
      actions: [TextButton(onPressed: onTurnOn, child: const Text('Turn on'))],
    );
  }
}
