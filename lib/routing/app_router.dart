import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../screens/home_page.dart';
import '../screens/login_page.dart';
import '../screens/welcome_page.dart';
import '../screens/profile_page.dart';
import '../screens/settings_page.dart';
import '../screens/chat_page.dart';
import '../screens/document_upload_page.dart';
import '../screens/shared_documents_page.dart';
import '../screens/signup_page.dart';
import '../providers/auth_state_provider.dart';
import '../providers/welcome_state_provider.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authNotifier = ref.watch(authStateProvider);
  final AsyncValue<bool> welcomeAsync = ref.watch(welcomeSeenProvider);

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
      GoRoute(path: '/signup', builder: (context, state) => const SignupPage()),
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
        path: '/document-upload',
        name: 'document-upload',
        builder: (context, state) => const DocumentUploadPage(),
      ),
      GoRoute(
        path: '/shared-documents',
        name: 'shared_documents',
        builder: (context, state) => const SharedDocumentsPage(),
      ),
    ],
    redirect: (context, state) {
      final bool loggedIn = authNotifier.currentUser != null;
      final String location = state.matchedLocation;

      // Wait for welcomeSeenProvider to load
      if (welcomeAsync.isLoading || welcomeAsync.hasError) {
        return null;
      }

      final bool hasSeenWelcome = welcomeAsync.value ?? false;

      if (!loggedIn) {
        if (!hasSeenWelcome && location != '/welcome') {
          return '/welcome';
        }
        if (hasSeenWelcome && location != '/login' && location != '/signup') {
          return '/login';
        }
      }

      if (loggedIn &&
          (location == '/login' ||
              location == '/signup' ||
              location == '/welcome')) {
        return '/';
      }

      return null;
    },
  );
});
