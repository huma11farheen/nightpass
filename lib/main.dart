import 'package:clubship/router.dart';
import 'package:clubship/supabase/config.dart';
import 'package:clubship/supabase/supabase_client.dart';
import 'package:clubship/theme.dart';
import 'package:clubship/utils/preference/preference_provider.dart';
import 'package:clubship/utils/preference/shared_preference.dart';
import 'package:clubship/notifications/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Preserve the native splash screen while initializing
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Config.load();
  await configureSupabase();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Set up background message handler
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Initialize notification service
  await NotificationService().initialize();

  // If user is already logged in, save FCM token
  final currentUser = supabase.auth.currentUser;
  if (currentUser != null) {
    try {
      await NotificationService().saveFCMToken();
      await NotificationService().subscribeToTopic('events');
    } catch (e) {
      // Don't fail app startup if notification setup fails
      print('Failed to setup notifications on startup: $e');
    }
  }

  final preferences = await SharedPreferences.initialize();

  // Remove the native splash screen after initialization
  FlutterNativeSplash.remove();

  runApp(ProviderScope(overrides: [
    preferencesProvider.overrideWithValue(preferences),
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
      theme: theme,
      debugShowCheckedModeBanner: false,
    );
  }
}
