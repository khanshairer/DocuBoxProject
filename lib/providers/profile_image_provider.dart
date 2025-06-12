import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_state_provider.dart';

/// A [StateNotifier] that manages the current user's profile image URL.
/// It actively fetches the image URL from Firebase Storage or Firestore based on the
/// authenticated user.
class ProfileImageStateNotifier extends StateNotifier<AsyncValue<String?>> {
  final Ref _ref;

  ProfileImageStateNotifier(this._ref) : super(const AsyncValue.loading()) {
    // Listen for authentication state changes immediately on creation
    _ref.listen<User?>(
      authStateProvider.select((notifier) => notifier.currentUser),
      (previousUser, newUser) {
        if (previousUser?.uid != newUser?.uid) {
          _fetchProfileImage();
        }
      },
      fireImmediately: true,
    );
  }

  /// Fetches the profile image URL from Firebase Storage.
  /// It first tries to get the URL from Firestore (which should hold the Storage URL).
  /// If not found in Firestore, it constructs a Storage reference to check there.
  Future<void> _fetchProfileImage() async {
    // Set state to loading if we are still mounted
    if (!mounted) return; // Add this check
    state = const AsyncValue.loading();

    try {
      final user = _ref.read(authStateProvider).currentUser;

      if (user != null && user.uid.isNotEmpty) {
        // --- Strategy 1: Check Firestore for imageUrl first (Recommended) ---
        final userDoc =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get();
        if (userDoc.exists && userDoc.data()!.containsKey('imageUrl')) {
          final firestoreImageUrl = userDoc.data()!['imageUrl'] as String?;
          if (firestoreImageUrl != null && firestoreImageUrl.isNotEmpty) {
            if (!mounted) return; // Add this check
            state = AsyncValue.data(firestoreImageUrl);
            return;
          }
        }

        // --- Strategy 2: If not in Firestore, try constructing Storage path (Fallback/Alternative) ---
        final imageRef = FirebaseStorage.instance.ref().child(
          'profile-pictures/${user.uid}.jpg',
        );

        final imageUrl = await imageRef.getDownloadURL();
        if (!mounted) return; // Add this check
        state = AsyncValue.data(imageUrl);

        // OPTIONAL: If found via Storage path, and not in Firestore,
        // consider saving it to Firestore for future faster retrieval.
        // Ensure this operation also happens only if mounted
        if (mounted) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({'imageUrl': imageUrl}, SetOptions(merge: true));
        }
      } else {
        if (!mounted) return; // Add this check
        // No authenticated user, or user UID is empty. Clear the image.
        state = const AsyncValue.data(null);
      }
    } on FirebaseException catch (e) {
      if (!mounted) return; // Add this check
      if (e.code == 'object-not-found' || e.code == 'not-found') {
        state = const AsyncValue.data(
          null,
        ); // Image simply doesn't exist for this user
      } else {
        state = AsyncValue.error(
          'Failed to load profile image: ${e.message}',
          StackTrace.current,
        );
      }
    } catch (e, st) {
      if (!mounted) return; // Add this check
      state = AsyncValue.error('Failed to load profile image: $e', st);
    }
  }

  /// Manually trigger a refresh of the profile image (e.g., after an upload).
  void refreshProfileImage() {
    _fetchProfileImage();
  }
}

/// Riverpod provider for the ProfileImageStateNotifier.
/// It uses .autoDispose to clean up resources when no longer needed.
final profileImageProvider = StateNotifierProvider.autoDispose<
  ProfileImageStateNotifier,
  AsyncValue<String?>
>((ref) {
  return ProfileImageStateNotifier(ref);
});
