import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart'; // We need this import for Scaffold and AppBar

import '../screens/home_page.dart';
import '../screens/login_page.dart';
import '../providers/auth_state_provider.dart';
import '../screens/welcome_page.dart';
import '../screens/document_upload_page.dart';
import '../screens/profile_page.dart';
import '../screens/shared_documents_page.dart'; // We're importing SharedDocumentsPage here

// This is our appRouterProvider, a Riverpod Provider that returns a GoRouter instance.
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
        path: '/profile', // Our consistent path for the profile screen
        name: 'profile',
        builder: (context, state) => const ProfilePage(), // Using our actual ProfilePage
      ),
      GoRoute(
        path: '/shared-documents',
        name: 'shared-documents',
        builder: (context, state) => const SharedDocumentsPage(),
      ),
      // Our placeholder routes for settings and chat, wrapped in Scaffold with const Text
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => Scaffold( // Removed const from Scaffold because AppBar is not const
          appBar: AppBar(title: const Text('Settings')), // Keeping const on Text
          body: const Center(child: Text('Settings Page Placeholder')), // Keeping const on Text
        ),
      ),
      GoRoute(
        path: '/chat',
        name: 'chat',
        builder: (context, state) => Scaffold( // Removed const from Scaffold because AppBar is not const
          appBar: AppBar(title: const Text('Chat')), // Keeping const on Text
          body: const Center(child: Text('Chat Page Placeholder')), // REMOVED UNNECESSARY CONST HERE
        ),
      ),
      // If '/see-document' is intended to be a viewer for a specific document,
      // its builder should navigate to SharedDocumentViewerPage or similar, passing the document ID.
      // For now, we're keeping it pointing to HomePage.
      GoRoute(
        path: '/see-document',
        name: 'see-document',
        builder: (context, state) => const HomePage(), 
      ),
    ],
    redirect: (context, state) {
      final bool loggedIn = authNotifier.currentUser != null;
      
      // Our list of routes that do NOT require authentication
      const List<String> publicRoutes = ['/welcome', '/login'];

      // Checking if the current location is one of the public routes
      final bool isPublicRoute = publicRoutes.contains(state.matchedLocation);

      // If not logged in AND trying to access a protected route (not a public route), we are redirecting to /welcome
      if (!loggedIn && !isPublicRoute) return '/welcome';
      
      // If logged in AND trying to access a public route, we are redirecting to home
      if (loggedIn && isPublicRoute) return '/';
      
      // Otherwise, no redirect is needed.
      return null;
    },
  );
});
