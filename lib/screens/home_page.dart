import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_state_provider.dart'; // Import your auth state provider
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
          // add an inconbutton with notification icon
          IconButton(onPressed: () {}, icon: Icon(Icons.notifications_active)),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero, // Remove default ListView padding
          children: <Widget>[
            // Drawer header, typically showing user info
            DrawerHeader(
              decoration: BoxDecoration(
                color:
                    Theme.of(
                      context,
                    ).colorScheme.primary, // Use primary theme color
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 30,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user.email ??
                        'Logged In User', // Display user email or a generic name
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            // Home option
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                context.go('/'); // Navigate to Home
              },
            ),
            // Profile option
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                context.go('/profile'); // Navigate to Profile
              },
            ),
            // Settings option
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                context.go('/settings'); // Navigate to Settings
              },
            ),
            // Chat option
            ListTile(
              leading: const Icon(Icons.chat),
              title: const Text('Chat'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                context.go('/chat'); // Navigate to Chat
              },
            ),
            const Divider(), // A visual divider
            // Logout option
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () async {
                Navigator.pop(context); // Close the drawer
                await authNotifier.signOut(); // Perform logout
                // GoRouter's redirect will handle navigation to login page
              },
            ),
          ],
        ),
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
