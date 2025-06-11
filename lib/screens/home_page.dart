import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import '../providers/auth_state_provider.dart';
//import by ajseby
import '../widget/homepage_menu_bar_widget.dart';
import 'package:go_router/go_router.dart';

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
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('DocuBox'),

        actions: [
          // upload Document
          IconButton(
            onPressed: () {
              context.go('/document-upload');
            },
            icon: Icon(Icons.upload),
          ),
          // add an inconbutton with notification icon
          IconButton(onPressed: () {}, icon: Icon(Icons.notifications_active)),
        ],
      ),
      // calling the homePageMenuBar with two named Parameter
      drawer: HomePageMenuBar(authNotifier: authNotifier, currentUser: user),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Welcome Section
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 60,
                      color: Colors.green.shade600,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'You are logged in!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Email: ${user.email ?? 'N/A'}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      'UID: ${user.uid}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
