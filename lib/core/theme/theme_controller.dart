import 'package:flutter/material.dart';
import 'package:cr_assist/core/storage/storage_service.dart';
import 'package:cr_assist/core/utils/constant.dart';

class ThemeController extends ChangeNotifier {
  ThemeController._()
      : _isDark = StorageService.get<bool>(Constants.keyDarkMode) ?? true;

  static final ThemeController instance = ThemeController._();

  bool _isDark;

  bool get isDark => _isDark;
  ThemeMode get mode => _isDark ? ThemeMode.dark : ThemeMode.light;

  Future<void> setDarkMode(bool value) async {
    if (_isDark == value) return;
    _isDark = value;
    notifyListeners();
    await StorageService.set(Constants.keyDarkMode, value);
  }

  Future<void> toggle() => setDarkMode(!_isDark);
}