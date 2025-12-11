import 'package:firebase_messaging/firebase_messaging.dart';

class PushNotificationService {
  static Future<void> init() async {
    final messaging = FirebaseMessaging.instance;

    await messaging.requestPermission(alert: true, sound: true, badge: true);
  }
}
