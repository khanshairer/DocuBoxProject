import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart'; // Import go_router for potential future navigation
import '../providers/auth_state_provider.dart'; // Import your auth state provider

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the authStateProvider to get the FirebaseAuthStateNotifier instance.
    // This widget will rebuild whenever authNotifier.notifyListeners() is called.
    final authNotifier = ref.watch(authStateProvider);
    final user =
        authNotifier
            .currentUser; // Directly access the current user from the notifier

    // Since GoRouter's redirect logic handles sending unauthenticated users
    // to the login page, this HomePage should only build when a user is logged in.
    // However, as a safety, we can still show a loading/error if the user object
    // somehow isn't available, or a simple placeholder while the redirect kicks in.
    if (user == null) {
      // This case should ideally be handled by GoRouter's redirect,
      // but a minimal empty container can act as a temporary placeholder
      // while the navigation system redirects the user.
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ), // Or SizedBox.shrink()
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome to DocuBox'),
        actions: [
          // Logout button
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              // Call the signOut method on your authNotifier.
              // This will update the authentication state and trigger GoRouter's redirect.
              await authNotifier.signOut();
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'You are logged in!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text('Email: ${user.email ?? 'N/A'}'),
            Text('UID: ${user.uid}'),
          ],
        ),
      ),
    );
  }
}
