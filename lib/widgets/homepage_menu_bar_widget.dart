import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_state_provider.dart';
import '../providers/profile_image_provider.dart'; // Ensure this import is correct

/// My custom Drawer widget for the HomePage menu.
/// It now directly watches necessary providers using Riverpod.
class HomePageMenuBar extends ConsumerWidget {
  // Keep as ConsumerWidget
  const HomePageMenuBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Access ref here
    final authNotifier = ref.watch(
      authStateProvider.notifier,
    ); // Get notifier for signOut
    final currentUser =
        ref.watch(authStateProvider).currentUser; // Watch current user
    final profileImageState = ref.watch(
      profileImageProvider,
    ); // Watch profile image state

    // Get the current user's display name or email, prioritizing display name
    final String userDisplayName =
        currentUser?.displayName?.isNotEmpty == true
            ? currentUser!.displayName!
            : currentUser?.email ?? 'Logged In User';

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero, // Remove default ListView padding
        children: <Widget>[
          // My Drawer header, showing user info and profile image
          DrawerHeader(
            decoration: BoxDecoration(
              color:
                  Theme.of(
                    context,
                  ).colorScheme.primary, // Uses theme's primary color
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor:
                      Theme.of(context)
                          .colorScheme
                          .onPrimary, // Background color that contrasts primary
                  // The child property is used here to show the loading indicator
                  child: ClipOval(
                    // Clip the image/icon to an oval shape
                    child: SizedBox.expand(
                      // Make the child fill the CircleAvatar
                      child:
                          (profileImageState.imageUrl != null &&
                                  profileImageState.imageUrl!.isNotEmpty)
                              ? Image.network(
                                profileImageState.imageUrl!,
                                fit: BoxFit.cover,
                                // Show a loading indicator while the image is loading
                                loadingBuilder: (
                                  BuildContext context,
                                  Widget child,
                                  ImageChunkEvent? loadingProgress,
                                ) {
                                  if (loadingProgress == null) {
                                    return child; // Image finished loading
                                  }
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value:
                                          loadingProgress
                                              .cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Theme.of(context).colorScheme.primary,
                                      ),
                                    ),
                                  );
                                },
                                // Show a person icon if the image fails to load
                                errorBuilder:
                                    (context, error, stackTrace) => Icon(
                                      Icons.person,
                                      size: 30,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                              )
                              : Icon(
                                // Fallback icon if no image URL
                                Icons.person,
                                size: 30,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  userDisplayName, // Display fetched user name or email
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color:
                        Theme.of(context)
                            .colorScheme
                            .onPrimary, // Text color that contrasts primary
                    fontWeight: FontWeight.bold,
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
                // Ensure widget is still mounted
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
                Navigator.pop(context);
                context.go('/document_upload');
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
              if (context.mounted) {
                Navigator.pop(context); // Close the drawer
              }
              await authNotifier.signOut(); // Perform logout
            },
          ),
        ],
      ),
    );
  }
}
