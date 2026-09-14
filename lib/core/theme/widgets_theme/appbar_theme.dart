import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../constants/colors.dart';
import '../../constants/sizes.dart';


class UAppBarTheme{
  UAppBarTheme._();

  static final lightAppBarTheme = AppBarTheme(
    elevation: 0,
    centerTitle: false,
    scrolledUnderElevation: 0,
    backgroundColor: Colors.transparent,
    surfaceTintColor: Colors.transparent,
    systemOverlayStyle: const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
    iconTheme: IconThemeData(color: UColors.black, size: USizes.iconMd),
    actionsIconTheme: IconThemeData(color: UColors.black, size: USizes.iconMd),
    titleTextStyle: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600, color: UColors.black),
  );
  static final darkAppBarTheme = AppBarTheme(
    elevation: 0,
    centerTitle: false,
    scrolledUnderElevation: 0,
    backgroundColor: Colors.transparent,
    surfaceTintColor: Colors.transparent,
    systemOverlayStyle: const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
    iconTheme: IconThemeData(color: UColors.white, size: USizes.iconMd),
    actionsIconTheme: IconThemeData(color: UColors.white, size: USizes.iconMd),
    titleTextStyle: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600, color: UColors.white),
  );
}
