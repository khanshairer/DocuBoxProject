import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import for User type
import '../providers/auth_state_provider.dart'; // Import your auth state notifier

/// A custom Drawer widget for the HomePage menu.
///
/// This widget requires [authNotifier] and [currentUser] to be passed in
/// from its parent widget (HomePage) as they are needed for actions
/// like logout and displaying user information.
class HomePageMenuBar extends StatelessWidget {
  final FirebaseAuthStateNotifier authNotifier;
  final User? currentUser;

  const HomePageMenuBar({
    super.key,
    required this.authNotifier,
    required this.currentUser,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
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
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 30,
                    color:
                        Colors
                            .blue, // Using a fixed blue for the icon, or Theme.of(context).colorScheme.primary
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  currentUser?.email ??
                      'Logged In User', // Use passed currentUser
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
          //upload option
          ListTile(
            leading: const Icon(Icons.mark_email_read),
            title: const Text('Upload Document'),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              context.go('/document-upload'); // Navigate to Home
            },
          ),
          // Profile option
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              context.go('/profile-page'); // Navigate to Profile
            },
          ),
          // Shared Documents option
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('Shared Documents'),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              context.go('/shared-documents'); // Navigate to Shared Documents
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
              await authNotifier
                  .signOut(); // Use passed authNotifier for logout
              // GoRouter's redirect will handle navigation to login page
            },
          ),
        ],
      ),
    );
  }
}
