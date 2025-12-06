import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/services.dart';

class AlarmService {
  cancelAlarm(int id) {
    platform.invokeMethod('cancelAlarm', {'id': id});
  }

  AlarmService._internal();
  static final AlarmService _instance = AlarmService._internal();
  factory AlarmService() => _instance;

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  static const platform = MethodChannel('com.example.diemember/alarm');
  Future<void> scheduleNativeAlarm({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    try {
      await platform.invokeMethod('scheduleAlarm', {
        'id': id,
        'title': title,
        'body': body,
        'time': scheduledTime.millisecondsSinceEpoch,
      });
    } catch (e) {
      debugPrint("Error scheduling native alarm: $e");
    }
  }

  Future<void> init() async {
    // 1️⃣ Notification permission
    if (await Permission.notification.isDenied) {
      final status = await Permission.notification.request();
      debugPrint(
        status.isGranted
            ? "✅ Notification permission granted"
            : "❌ Notification permission denied",
      );
    } else {
      debugPrint("✅ Notification permission already granted");
    }

    // 2️⃣ Exact alarm permission
    if (await Permission.scheduleExactAlarm.isDenied) {
      final status = await Permission.scheduleExactAlarm.status;

      debugPrint(
        status.isGranted
            ? "✅ Exact alarm permission granted"
            : "❌ Exact alarm permission denied",
      );
    } else {
      final status = await Permission.scheduleExactAlarm.status;

      debugPrint("Exact alarm permission status: $status");

      debugPrint("✅ Exact alarm permission already granted");
    }

    // Android initialization
    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings = InitializationSettings(
      android: androidInit,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        debugPrint("Notification tapped: ${response.actionId}");
      },
    );

    debugPrint("✅ Notification Service initialized");
  }
}
