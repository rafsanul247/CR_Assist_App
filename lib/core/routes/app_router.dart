import 'package:cr_assist/core/common/r_bottom_navbar.dart';
import 'package:cr_assist/core/storage/storage_service.dart';
import 'package:cr_assist/core/utils/constant.dart';
import 'package:cr_assist/features/auth/presentation/views/class_code/class_code.dart';
import 'package:cr_assist/features/auth/presentation/views/login_screen/login_screen.dart';
import 'package:cr_assist/features/auth/presentation/views/registration_screen/registration_screen.dart';
import 'package:cr_assist/features/notice/presentation/views/notice_screen.dart';
import 'package:cr_assist/features/semesters/presentation/views/subject_list_view/subject_list_view.dart';
import 'package:cr_assist/features/semesters/presentation/views/resource_list_view/resource_list_view.dart';
import 'package:cr_assist/features/settings/presentation/views/about_cr_assistant/about_cr_assistant.dart';
import 'package:cr_assist/features/settings/presentation/views/profile/profile.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  AppRouter._();

  static GoRouter get router => _router;

  static final GoRouter _router = GoRouter(
    initialLocation: StorageService.containsKey(Constants.keyAuthToken)
        ? '/main'
        : '/login',
    debugLogDiagnostics: false,

    redirect: (context, state) {
      final bool loggedIn = StorageService.containsKey(Constants.keyAuthToken);
      final bool isAuth = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/class-code';

      if (!loggedIn && !isAuth) return '/login';
      if (loggedIn && isAuth) return '/main';

      return null;
    },

    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        pageBuilder: (context, state) => _page(state, const LoginScreen()),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        pageBuilder: (context, state) => _page(state, const RegistrationScreen()),
      ),
      GoRoute(
        path: '/class-code',
        name: 'class-code',
        pageBuilder: (context, state) => _page(state, const ClassCode()),
      ),
      GoRoute(
        path: '/main',
        name: 'main',
        pageBuilder: (context, state) => _page(state, const MainScreen()),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        pageBuilder: (context, state) => _page(state, const ProfileScreen()),
      ),
      GoRoute(
        path: '/notice',
        name: 'notice',
        pageBuilder: (context, state) => _page(state, const NoticeScreen()),
      ),
      GoRoute(
        path: '/subjects',
        name: 'subjects',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return _page(state, SubjectListView(
            semesterId: extra['semesterId'] as int? ?? 0,
            semesterName: extra['semesterName'] as String? ?? 'Subjects',
          ));
        },
      ),
      GoRoute(
        path: '/resources',
        name: 'resources',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return _page(state, ResourceListView(
            subjectId: extra['subjectId'] as int? ?? 0,
            subjectName: extra['subjectName'] as String? ?? 'Resources',
          ));
        },
      ),
      GoRoute(
        path: '/about',
        name: 'about',
        pageBuilder: (context, state) => _page(state, const AboutCrAssistant()),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Error: ${state.error}'),
      ),
    ),
  );

  static CustomTransitionPage<void> _page(GoRouterState state, Widget child) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 360),
      reverseTransitionDuration: const Duration(milliseconds: 280),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(begin: const Offset(0.04, 0), end: Offset.zero).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  static void go(String path) {
    _router.go(path);
  }

  static Future<T?> push<T extends Object?>(
      String path, {
        Object? extra,
      }) {
    return _router.push<T>(path, extra: extra);
  }

  static void pop<T extends Object?>([T? result]) {
    _router.pop<T>(result);
  }
}
