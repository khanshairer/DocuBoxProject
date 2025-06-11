import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/auth_state_provider.dart';

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
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
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
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  currentUser?.email ?? 'Logged In User',
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
              context.go('/'); // Navigate to Home (root path)
            },
          ),
          // My Documents option - will navigate to the HomePage which has search
          ListTile(
            leading: const Icon(Icons.folder_outlined),
            title: const Text('My Documents'),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              context.go('/'); // Navigate to Home (root path which is 'My Documents' now)
            },
          ),
          // Upload Document option
          ListTile(
            leading: const Icon(Icons.upload_file),
            title: const Text('Upload Document'),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              context.push('/document-upload'); // Use context.push for the upload page
            },
          ),
          // Profile option
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              context.push('/profile'); // Use context.push for profile
            },
          ),
          // Settings option
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              context.push('/settings'); // Use context.push for settings
            },
          ),
          // Chat option
          ListTile(
            leading: const Icon(Icons.chat),
            title: const Text('Chat'),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              context.push('/chat'); // Use context.push for chat
            },
          ),
          const Divider(),
          // Logout option
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () async {
              Navigator.pop(context);
              await authNotifier.signOut();
            },
          ),
        ],
      ),
    );
  }
}
