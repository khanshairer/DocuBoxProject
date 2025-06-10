import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'screens/home_page.dart';
import 'screens/welcome_page.dart';
import 'providers/auth_state_provider.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Start the app with ProviderScope for state management
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the authentication state
    final authState = ref.watch(authStateProvider);

    return MaterialApp(
      title: 'DocuBox',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: authState.when(
        // If user is logged in, show HomePage; otherwise WelcomePage
        data: (user) => user != null ? const HomePage() : const WelcomePage(),

        // Show loading indicator while checking auth state
        loading:
            () => const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),

        // Show error message if something went wrong
        error:
            (error, stackTrace) => Scaffold(
              body: Center(child: Text('Error: ${error.toString()}')),
            ),
      ),
      // Optional: Define routes if you're using navigation
      routes: {
        '/home': (context) => const HomePage(),
        '/welcome': (context) => const WelcomePage(),
      },
    );
  }
}
