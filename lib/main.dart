import 'package:flutter/material.dart';
import 'app.dart';
import 'core/storage/storage_service.dart';
import 'injection.dart';

export 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await StorageService.init();

  // Initialize Dependency Injection
  await init();

  runApp(const MyApp());
}
