import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'common/app_theme.dart';
import 'common/dark_theme.dart';
import 'routing/app_router.dart'; // Assuming your router file is in lib/router/app_router.dart
import 'providers/theme_settings_provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'services/notification_service.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // This runs when app receives FCM while in background/terminated
  debugPrint('Background FCM received: ${message.notification?.title}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with platform-specific options.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await NotificationService.initialize(); // <- initialize local + FCM

  // Run the app, wrapped in ProviderScope for Riverpod state management.
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(appRouterProvider);
    final themeSettings = ref.watch(themeSettingsProvider);

    // Validate theme settings to prevent null errors
    final effectiveFontSizeFactor = themeSettings.fontSizeFactor.clamp(
      0.8,
      1.5,
    );
    final effectiveBrightnessFactor = themeSettings.brightnessFactor.clamp(
      0.7,
      1.3,
    );

    return MaterialApp.router(
      title: 'DocuBox',
      debugShowCheckedModeBanner: false,
      themeMode: themeSettings.themeMode,
      theme: _buildTheme(
        isDark: false,
        fontSizeFactor: effectiveFontSizeFactor,
        brightnessFactor: effectiveBrightnessFactor,
      ),
      darkTheme: _buildTheme(
        isDark: true,
        fontSizeFactor: effectiveFontSizeFactor,
        brightnessFactor: effectiveBrightnessFactor,
      ),
      routerConfig: goRouter,
    );
  }

  ThemeData _buildTheme({
    required bool isDark,
    required double fontSizeFactor,
    required double brightnessFactor,
  }) {
    try {
      // Get the base theme
      final baseTheme =
          isDark
              ? DarkTheme.darkTheme(
                fontSizeFactor: fontSizeFactor,
                brightnessFactor: brightnessFactor,
              )
              : AppTheme.lightTheme(
                fontSizeFactor: fontSizeFactor,
                brightnessFactor: brightnessFactor,
              );

      // Ensure all text styles have proper font sizes
      return baseTheme.copyWith(
        textTheme: baseTheme.textTheme.apply(
          fontSizeFactor: fontSizeFactor,
          bodyColor: baseTheme.textTheme.bodyLarge?.color,
          displayColor: baseTheme.textTheme.bodyLarge?.color,
        ),
      );
    } catch (e) {
      debugPrint('Error building theme: $e');
      return ThemeData(
        brightness: isDark ? Brightness.dark : Brightness.light,
        textTheme: TextTheme(
          bodyLarge: TextStyle(fontSize: 16.0 * fontSizeFactor),
          bodyMedium: TextStyle(fontSize: 14.0 * fontSizeFactor),
        ),
      );
    }
  }
}
