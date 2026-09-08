import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/theme/app_theme.dart';
import 'core/routes/app_router.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 800),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          routerConfig: AppRouter.router,
          // Remove debug banner
          debugShowCheckedModeBanner: false,
          // App title (shows in task switcher)
          title: 'App',

          theme: AppTheme.lightTheme(context),

          darkTheme: AppTheme.darkTheme(context),
          // Use system theme mode (light/dark based on device settings)
          themeMode: ThemeMode.system,
        );
      },
    );
  }
}
