import 'dart:async';

import 'package:cr_assist/core/network/dio_client.dart';
import 'package:cr_assist/core/utils/api_endpoint.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class FcmService {
  FcmService({required this._dioClient});

  final DioClient _dioClient;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  StreamSubscription<String>? _tokenSubscription;
  String? _currentTopic;

  /// Normalizes one part of the backend topic name.
  static String normalizeTopicPart(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
  }

  /// Builds the topic shared with the backend.
  /// Format: university_department_batch_batchName
  static String? buildBatchTopic({
    required String universityName,
    required String deptName,
    required String batchName,
  }) {
    final university = normalizeTopicPart(universityName);
    final department = normalizeTopicPart(deptName);
    final batch = normalizeTopicPart(batchName);

    if (university.isEmpty || department.isEmpty || batch.isEmpty) {
      return null;
    }

    return '${university}_${department}_batch_$batch';
  }

  /// Registers this device with the API and subscribes users to their batch topic.
  Future<void> syncTokenWithBackend({
    required int batchId,
    required String role,
    String? universityName,
    String? deptName,
    String? batchName,
  }) async {
    debugPrint(
      '[FCM] sync started: role=$role, batchId=$batchId, '
          'university=$universityName, department=$deptName, batch=$batchName',
    );

    if (universityName == null ||
        deptName == null ||
        batchName == null ||
        universityName.trim().isEmpty ||
        deptName.trim().isEmpty ||
        batchName.trim().isEmpty) {
      debugPrint(
        '[FCM] topic subscription skipped: missing batch data '
            '(university: $universityName, department: $deptName, batch: $batchName)',
      );
    } else {
      final topic = buildBatchTopic(
        universityName: universityName,
        deptName: deptName,
        batchName: batchName,
      );

      if (topic != null) {
        debugPrint('[FCM] university: $universityName');
        debugPrint('[FCM] department: $deptName');
        debugPrint('[FCM] batch: $batchName');
        debugPrint('[FCM] final topic: $topic');
        await _subscribeToTopic(topic);
      } else {
        debugPrint('[FCM] topic generation failed due to invalid names');
      }
    }

    final token = await _messaging.getToken();
    if (token == null || batchId <= 0) {
      debugPrint(
        '[FCM] token sync skipped: token=${token != null}, batchId=$batchId',
      );
      return;
    }

    debugPrint('[FCM] device token available; registering token with backend');

    await _registerToken(
      token: token,
      batchId: batchId,
      role: role,
    );

    _tokenSubscription ??= _messaging.onTokenRefresh.listen((newToken) {
      _registerToken(
        token: newToken,
        batchId: batchId,
        role: role,
      );
    });
  }

  Future<void> _subscribeToTopic(String topic) async {
    if (_currentTopic == topic) {
      debugPrint('[FCM] already subscribed to topic: $topic');
      return;
    }

    try {
      if (_currentTopic != null) {
        debugPrint('[FCM] unsubscribing from old topic: $_currentTopic');
        await _messaging.unsubscribeFromTopic(_currentTopic!);
      }

      debugPrint('[FCM] subscribing to topic: $topic');
      await _messaging.subscribeToTopic(topic);
      _currentTopic = topic;

      print('🚀 [FCM] Subscribed to topic: $topic');
    } catch (error, stackTrace) {
      print('❌ [FCM] topic subscription failed for $topic: $error');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Call this ONLY when user logs out.
  Future<void> unsubscribeFromCurrentTopic() async {
    if (_currentTopic != null) {
      await _messaging.unsubscribeFromTopic(_currentTopic!);
      print('📴 [FCM] Unsubscribed from topic: $_currentTopic');
      _currentTopic = null;
    }
  }

  Future<void> _registerToken({
    required String token,
    required int batchId,
    required String role,
  }) async {
    try {
      await _dioClient.post(
        ApiEndpoint.fcmToken,
        data: {
          'token': token,
          'batchId': batchId,
          'role': role,
          'platform': defaultTargetPlatform.name,
        },
      );
      debugPrint('[FCM] token registered with backend successfully');
    } catch (error) {
      debugPrint('[FCM] token sync failed: $error');
    }
  }

  Future<void> dispose() async {
    await _tokenSubscription?.cancel();
    _tokenSubscription = null;
    // NOTE: Topic unsubscribe is removed from here so background messages stay active.
  }
}