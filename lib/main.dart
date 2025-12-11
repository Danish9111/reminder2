import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:reminder_app/auth_wrapper.dart';
import 'package:reminder_app/providers/chat_provider.dart';
import 'package:reminder_app/providers/family_provider.dart';
import 'package:reminder_app/providers/task_provider.dart';
import 'package:reminder_app/providers/auth_provider.dart';
import 'package:reminder_app/providers/user_provider.dart';
import 'package:reminder_app/services/push_notification_service.dart';
import 'package:reminder_app/widgets/custom_snackbar.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Register background message handler
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Initialize push notifications
  await PushNotificationService.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => FamilyProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey, // Required for Snackbar
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF9B59B6)),
          useMaterial3: true,
        ),
        // home: const BottomNavigationScreen(),
        home: const AuthWrapper(),
      ),
    );
  }
}
