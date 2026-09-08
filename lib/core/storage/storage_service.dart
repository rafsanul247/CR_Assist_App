import 'package:hive_flutter/hive_flutter.dart';

/// Centralized Local Storage Service using Hive
class StorageService {
  static Box? _box;

  /// Initialize Hive and open default storage box
  static Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox('app_storage');
  }

  /// Get value by key with Type Safety
  static T? get<T>(String key, {T? defaultValue}) {
    return _box?.get(key, defaultValue: defaultValue) as T?;
  }

  /// Set key-value pair
  static Future<void> set(String key, dynamic value) async {
    await _box?.put(key, value);
  }

  /// Delete value by key
  static Future<void> delete(String key) async {
    await _box?.delete(key);
  }

  /// Clear all stored data
  static Future<void> clear() async {
    await _box?.clear();
  }

  /// Check if key exists
  static bool containsKey(String key) {
    return _box?.containsKey(key) ?? false;
  }

  /// Get all keys as a list
  static List<String> getAllKeys() {
    return _box?.keys.cast<String>().toList() ?? [];
  }

  /// Close box instance
  static Future<void> close() async {
    await _box?.close();
  }
}
