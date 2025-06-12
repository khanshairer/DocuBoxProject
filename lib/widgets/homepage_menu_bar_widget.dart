import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/auth_state_provider.dart';

/// My custom Drawer widget for the HomePage menu.
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
          // My Drawer header, typically showing user info
          DrawerHeader(
            decoration: BoxDecoration(
              color:
                  Theme.of(
                    context,
                  ).colorScheme.primary, // Using primary theme color
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
                      'Logged In User', // Using passed currentUser
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // Home option (My Documents) - consistent with Home Page
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'), // Clearer label
            onTap: () {
              context.go('/'); // Navigating to Home (root path)
            },
          ),
          // Upload Document option - changed to push for consistent stack
          ListTile(
            leading: const Icon(Icons.upload_file), // Changed icon for clarity
            title: const Text('Upload Document'),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              context.push('/document-upload'); // Using context.push
            },
          ),
          // Shared Documents option - changed to push for consistent stack
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('Shared Documents'),
            onTap: () {
              context.go('/shared-documents'); // Using context.push
            },
          ),
          // Profile option - changed to push for consistent stack & path
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              context.go(
                '/profile',
              ); // Using context.push, path is now /profile
            },
          ),
          // Settings option - changed to push for consistent stack
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              context.go('/settings'); // Using context.push
            },
          ),
          // Chat option - changed to push for consistent stack
          ListTile(
            leading: const Icon(Icons.chat),
            title: const Text('Chat'),
            onTap: () {
              context.go('/chat'); // Using context.push
            },
          ),

          const Divider(), // My visual divider
          // Logout option
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () async {
              context.pop();
              await authNotifier.signOut();
            },
          ),
        ],
      ),
    );
  }
}
