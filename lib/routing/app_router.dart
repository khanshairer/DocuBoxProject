import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../screens/home_page.dart';
import '../screens/login_page.dart';
import '../providers/auth_state_provider.dart'; // This is the updated import
import '../screens/welcome_page.dart';
import '../screens/document_upload_page.dart';
import '../screens/shared_documents_page.dart';
import '../screens//profile_page.dart';

// The appRouterProvider is a Riverpod Provider that returns a GoRouter instance.
final appRouterProvider = Provider<GoRouter>((ref) {
  // We watch the authStateProvider which now provides our FirebaseAuthStateNotifier.
  // Since FirebaseAuthStateNotifier extends ChangeNotifier, it is a Listenable.
  final authNotifier = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',
    // Pass the authNotifier directly as the refreshListenable.
    // GoRouter will automatically re-evaluate redirects when authNotifier calls notifyListeners().
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
        path: '/shared-documents',
        name: 'shared-documents',
        builder: (context, state) => const SharedDocumentsPage(),
      ),
      GoRoute(
        path: '/see-document',
        name: 'see-document',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/profile-page',
        name: 'profile-page',
        builder: (context, state) => const ProfilePage(),
      ),
    ],
    redirect: (context, state) {
      // Use the currentUser from the authNotifier to determine login status.
      final bool loggedIn = authNotifier.currentUser != null;
      // Check if the current location being navigated to is the login page.
      final bool loggingIn = state.matchedLocation == '/login';

      // If not logged in and not trying to log in, redirect to login.
      if (!loggedIn && !loggingIn) return '/welcome';
      // If logged in and trying to access login, redirect to home.
      if (loggedIn && loggingIn) return '/';
      // Otherwise, no redirect needed.
      return null;
    },
  );
});
