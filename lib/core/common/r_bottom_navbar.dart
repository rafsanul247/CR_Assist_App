import 'package:cr_assist/core/constants/colors.dart';
import 'package:cr_assist/features/notice/presentation/views/notice_screen.dart';
import 'package:cr_assist/features/semesters/presentation/views/semester_list_view/semester_list_view.dart';
import 'package:cr_assist/features/settings/presentation/views/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;
  const MainScreen({super.key, this.initialIndex = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
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
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Theme(
        // ১. এখানে স্প্ল্যাশ এবং আইকন প্রেসড ইফেক্ট পুরোপুরি বন্ধ করা হয়েছে
        data: Theme.of(context).copyWith(
          splashFactory: NoSplash.splashFactory, // আঙুলের ছোপ বা রিপল বন্ধ করবে
          highlightColor: Colors.transparent,   // চেপে রাখলে হওয়া হাইলাইট বন্ধ করবে
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
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Iconsax.home),
                label: 'Home',
              ),
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