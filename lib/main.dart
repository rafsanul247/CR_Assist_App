import 'package:cr_assist/core/services/fcm_and_local_messaging_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'core/storage/storage_service.dart';
import 'firebase_options.dart';
import 'injection.dart';

export 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Notification Service (FCM & Local Notifications)
  await NotificationService().initialize();

  // Initialize Hive
  await StorageService.init();

  // Initialize Dependency Injection
  await init();

  runApp(const MyApp());
}
