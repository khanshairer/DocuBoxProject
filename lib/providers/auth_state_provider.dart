import 'package:flutter/foundation.dart'; // Required for ChangeNotifier
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async'; // Required for StreamSubscription
import '../services/user_service.dart';

/// A ChangeNotifier that listens to Firebase Authentication state changes.
/// This notifier will call notifyListeners() whenever the user's authentication
/// status changes, which can then be used by GoRouter's refreshListenable.
class FirebaseAuthStateNotifier extends ChangeNotifier {
  StreamSubscription<User?>? _userSubscription;
  User? _currentUser;

  /// Exposes the current Firebase user.
  User? get currentUser => _currentUser;

  FirebaseAuthStateNotifier() {
    // Listen to Firebase auth state changes
    _userSubscription = FirebaseAuth.instance.authStateChanges().listen((user) async {
      _currentUser = user;
      
      // If a user just signed in, add them to the users collection
      if (user != null) {
        try {
          await UserService.addCurrentUserToCollection();
        } catch (e) {
          // Log error but don't prevent authentication
        }
      }
      
      // Notify all listeners (including GoRouter's refreshListenable)
      // that the authentication state has changed.
      notifyListeners();
    });
  }

  /// Optional: Example method to sign out the user.
  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  void dispose() {
    // Cancel the subscription when the notifier is disposed to prevent memory leaks.
    _userSubscription?.cancel();
    super.dispose();
  }
}

/// Riverpod provider that provides an instance of FirebaseAuthStateNotifier.
/// This provider is a ChangeNotifierProvider, meaning it provides a Listenable
/// object that can be used directly with GoRouter's refreshListenable.
final authStateProvider = ChangeNotifierProvider<FirebaseAuthStateNotifier>((
  ref,
) {
  final notifier = FirebaseAuthStateNotifier();
  // Ensure the notifier's dispose method is called when the provider is no longer used.
  ref.onDispose(() => notifier.dispose());
  return notifier;
});
