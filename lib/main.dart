import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'common/app_theme.dart';
import 'common/dark_theme.dart';
// Import your GoRouter provider
import 'routing/app_router.dart'; // Assuming your router file is in lib/router/app_router.dart
import 'providers/theme_settings_provider.dart';

void main() async {
  // Ensure Flutter binding is initialized before Firebase.
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with platform-specific options.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Run the app, wrapped in ProviderScope for Riverpod state management.
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Obtain the GoRouter instance from the appRouterProvider.
    // Riverpod will ensure this is properly initialized and updated.
    final goRouter = ref.watch(appRouterProvider);
    final themeSettings = ref.watch(themeSettingsProvider);

    return MaterialApp.router(
      title: 'DocuBox',
      debugShowCheckedModeBanner: false,
      // CORRECTED: Use your external theme data here
      themeMode: themeSettings.themeMode,
      // FIX 1: You MUST CALL the static lightTheme method with parameters.
      theme: AppTheme.lightTheme(
        // <--- THIS LINE HAS BEEN CHANGED to call the method
        fontSizeFactor: themeSettings.fontSizeFactor,
        brightnessFactor: themeSettings.brightnessFactor,
      ),
      // FIX 2: You MUST CALL the static darkTheme method with parameters.
      darkTheme: DarkTheme.darkTheme(
        // <--- THIS LINE HAS BEEN CHANGED to call the method
        fontSizeFactor: themeSettings.fontSizeFactor,
        brightnessFactor: themeSettings.brightnessFactor,
      ), // <--- THIS LINE WAS THE ISSUE!
      // Assign the GoRouter's routerConfig to MaterialApp.router
      routerConfig: goRouter,

      // The 'home' and 'routes' properties are no longer needed
      // because GoRouter handles all navigation.
      // The redirection logic in app_router.dart will decide
      // whether to show HomePage or WelcomePage based on auth state.
    );
  }
}
