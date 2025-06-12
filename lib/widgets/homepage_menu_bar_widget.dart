import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/profile_image_provider.dart'; // Ensure this import is correct

class HomePageMenuBar extends ConsumerWidget {
  const HomePageMenuBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final profileImageState = ref.watch(
      profileImageProvider,
    ); // This is an AsyncValue<String?>

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
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  child: profileImageState.when(
                    data: (imageUrl) {
                      return imageUrl != null && imageUrl.isNotEmpty
                          ? ClipOval(
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              width: 60,
                              height: 60,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withAlpha((255 * 0.6).round()),
                                );
                              },
                            ),
                          )
                          : Icon(
                            Icons.person,
                            size: 60,
                            color: Theme.of(context).colorScheme.onSurface
                                .withAlpha((255 * 0.6).round()),
                          );
                    },
                    loading:
                        () => CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                    error:
                        (err, stack) => Icon(
                          Icons.error,
                          color: Theme.of(context).colorScheme.error,
                          size: 60,
                        ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  currentUser?.displayName ?? currentUser?.email ?? 'Guest',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 18,
                  ),
                ),
                Text(
                  currentUser?.email ?? '',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary.withAlpha(
                      (255 * 0.7).round(),
                    ), // <--- CHANGED HERE
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          // Home option (My Documents)
          ListTile(
            leading: Icon(
              Icons.home,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            title: Text(
              'Home',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
            onTap: () {
              if (context.mounted) {
                Navigator.pop(context); // Close the drawer
                context.go('/'); // Navigate to Home (root path)
              }
            },
          ),
          // Upload Document option
          ListTile(
            leading: Icon(
              Icons.upload_file,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            title: Text(
              'Upload Document',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
            onTap: () {
              if (context.mounted) {
                Navigator.pop(context); // Close the drawer
                context.go('/document-upload');
              }
            },
          ),
          // Shared Documents option
          ListTile(
            leading: Icon(
              Icons.share,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            title: Text(
              'Shared Documents',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
            onTap: () {
              if (context.mounted) {
                Navigator.pop(context);
                context.go('/shared-documents');
              }
            },
          ),
          // Profile option
          ListTile(
            leading: Icon(
              Icons.person,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            title: Text(
              'Profile',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
            onTap: () {
              if (context.mounted) {
                Navigator.pop(context);
                context.go('/profile');
              }
            },
          ),
          // Settings option
          ListTile(
            leading: Icon(
              Icons.settings,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            title: Text(
              'Settings',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
            onTap: () {
              if (context.mounted) {
                Navigator.pop(context);
                context.go('/settings');
              }
            },
          ),
          // Chat option
          ListTile(
            leading: Icon(
              Icons.chat,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            title: Text(
              'Chat',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
            onTap: () {
              if (context.mounted) {
                Navigator.pop(context);
                context.go('/chat');
              }
            },
          ),
          const Divider(), // My visual divider
          // Logout option
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.pop(context); // Close the drawer
                context.go(
                  '/auth',
                ); // Navigate to authentication page (assuming this is your login screen)
              }
            },
          ),
        ],
      ),
    );
  }
}
