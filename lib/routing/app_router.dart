import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

import '../screens/home_page.dart';
import '../screens/login_page.dart';
import '../providers/auth_state_provider.dart';
import '../screens/welcome_page.dart';
import '../screens/document_upload_page.dart';
import '../screens/profile_page.dart';
import '../screens/shared_documents_page.dart';
import '../screens/settings_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authNotifier = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: authNotifier,
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/welcome',
        name: 'welcome',
        builder: (context, state) => const WelcomePage(),
      ),
      GoRoute(
        path: '/document-upload',
        name: 'document-upload',
        builder: (context, state) => const DocumentUploadPage(),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: '/shared-documents',
        name: 'shared-documents',
        builder: (context, state) => const SharedDocumentsPage(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: '/chat',
        name: 'chat',
        builder:
            (context, state) => Scaffold(
              appBar: AppBar(title: const Text('Chat')),
              body: const Center(child: Text('Chat Page Placeholder')),
            ),
      ),
      GoRoute(
        path: '/see-document',
        name: 'see-document',
        builder: (context, state) => const HomePage(),
      ),
    ],
    errorBuilder:
        (context, state) => Scaffold(
          appBar: AppBar(title: const Text('Error')),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Page Not Found',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'The requested page could not be found',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => context.go('/'),
                  child: const Text('Return to Home'),
                ),
              ],
            ),
          ),
        ),
    redirect: (context, state) {
      final bool loggedIn = authNotifier.currentUser != null;
      const List<String> publicRoutes = ['/welcome', '/login'];
      final bool isPublicRoute = publicRoutes.contains(state.matchedLocation);

      if (!loggedIn && !isPublicRoute) return '/welcome';
      if (loggedIn && isPublicRoute) return '/';
      return null;
    },
  );
});
