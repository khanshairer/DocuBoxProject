import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart'; // Ensure Material.dart is imported for Scaffold

import '../screens/home_page.dart';
import '../screens/login_page.dart';
import '../providers/auth_state_provider.dart';
import '../screens/welcome_page.dart';
import '../screens/document_upload_page.dart';
import '../screens/profile_page.dart'; 

// The appRouterProvider is a Riverpod Provider that returns a GoRouter instance.
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
        path: '/settings',
        name: 'settings',
        builder: (context, state) => Scaffold( 
          appBar: AppBar(title: const Text('Settings')),
          body: const Center(child: Text('Settings Page Placeholder')),
        ),
      ),
      GoRoute(
        path: '/chat',
        name: 'chat',
        builder: (context, state) => Scaffold( 
          appBar: AppBar(title: const Text('Chat')),
          body: const Center(child: Text('Chat Page Placeholder')),
        ),
      ),
    ],
    redirect: (context, state) {
      final bool loggedIn = authNotifier.currentUser != null;
      
      // List of routes that do NOT require authentication
      const List<String> publicRoutes = ['/welcome', '/login'];

      // Check if the current location is one of the public routes
      final bool isPublicRoute = publicRoutes.contains(state.matchedLocation);

      // If not logged in AND trying to access a protected route (not a public route), redirect to /welcome
      if (!loggedIn && !isPublicRoute) return '/welcome';
      
      // If logged in AND trying to access a public route, redirect to home
      if (loggedIn && isPublicRoute) return '/';
      
      // Otherwise, no redirect needed.
      return null;
    },
  );
});
