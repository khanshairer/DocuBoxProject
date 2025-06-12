import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../screens/home_page.dart';
import '../screens/login_page.dart';
import '../screens/welcome_page.dart';
import '../screens/profile_page.dart';
import '../screens/settings_page.dart';
import '../screens/chat_page.dart';
import '../screens/document_upload_page.dart'; // NEW IMPORT: For document upload page
import '../screens/shared_documents_page.dart'; // NEW IMPORT: For shared documents page
import '../providers/auth_state_provider.dart';

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
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: '/chat',
        name: 'chat',
        builder: (context, state) => const ChatPage(),
      ),
      GoRoute(
        // NEW ROUTE: For Document Upload Page
        path: '/document-upload',
        name: 'document-upload',
        builder: (context, state) => const DocumentUploadPage(),
      ),
      GoRoute(
        // NEW ROUTE: For Shared Documents Page
        path: '/shared-documents',
        name: 'shared_documents',
        builder: (context, state) => const SharedDocumentsPage(),
      ),
    ],
    redirect: (context, state) {
      final bool loggedIn = authNotifier.currentUser != null;
      final bool loggingIn = state.matchedLocation == '/login';
      final bool onWelcome = state.matchedLocation == '/welcome';

      // If not logged in and not on login/welcome, redirect to welcome
      if (!loggedIn && !loggingIn && !onWelcome) return '/welcome';
      // If logged in and trying to access login/welcome, redirect to home
      if (loggedIn && (loggingIn || onWelcome)) return '/';
      // Otherwise, no redirect needed.
      return null;
    },
  );
});
