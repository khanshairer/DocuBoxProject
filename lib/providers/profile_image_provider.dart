import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A [ChangeNotifier] that holds and updates the current user's profile image URL.
/// This allows other parts of the app (like a Drawer or AppBar) to react to
/// profile image changes in real-time.
class ProfileImageNotifier extends ChangeNotifier {
  String? _imageUrl;

  String? get imageUrl => _imageUrl;

  /// Updates the profile image URL and notifies listeners.
  void updateImage(String? newUrl) {
    if (_imageUrl != newUrl) {
      _imageUrl = newUrl;
      notifyListeners();
    }
  }
}

/// Riverpod provider for the ProfileImageNotifier.
final profileImageProvider = ChangeNotifierProvider(
  (ref) => ProfileImageNotifier(),
);
