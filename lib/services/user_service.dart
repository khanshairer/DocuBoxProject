import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user.dart';
import 'package:flutter/foundation.dart';


class UserService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Add current user to the users collection if they don't exist
  static Future<void> addCurrentUserToCollection() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No authenticated user found');
    }

    try {
      // Check if user already exists
      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (!userDoc.exists) {
        // Create new user document
        final appUser = AppUser(
          uid: user.uid,
          email: user.email ?? '',
          displayName: user.displayName,
          createdAt: DateTime.now(),
        );

        await _firestore
            .collection('users')
            .doc(user.uid)
            .set(appUser.toFirestore());
      } else {
        // Optionally update user info if it has changed
        final existingData = userDoc.data();
        if (existingData != null) {
          bool needsUpdate = false;
          Map<String, dynamic> updates = {};

          if (existingData['email'] != user.email) {
            updates['email'] = user.email ?? '';
            needsUpdate = true;
          }

          if (existingData['displayName'] != user.displayName) {
            updates['displayName'] = user.displayName;
            needsUpdate = true;
          }

          if (needsUpdate) {
            await _firestore.collection('users').doc(user.uid).update(updates);
          }
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> saveUserToken(String token, {bool? notificationsEnabled}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
     final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

     // Build the update payload
      final Map<String, dynamic> updates = {
       'fcmTokens': FieldValue.arrayUnion([token]),
     };

      // Optionally update notification setting
      if (notificationsEnabled != null) {
       updates['notificationsEnabled'] = notificationsEnabled;
      }

     await userRef.set(updates, SetOptions(merge: true));
    } catch (e) {
     debugPrint('Error saving user token/settings: $e');
    }
  }

  /// Get all users from the collection
  static Future<List<AppUser>> getAllUsers() async {
    try {
      final snapshot = await _firestore.collection('users').get();
      return snapshot.docs.map((doc) => AppUser.fromFirestore(doc)).toList();
    } catch (e) {
      // Error getting users
      rethrow;
    }
  }

  static Future<void> updateNotificationPreference(bool enabled) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final ref = FirebaseFirestore.instance.collection('users').doc(user.uid);
      await ref.set({'notificationsEnabled': enabled}, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Failed to update notification setting: $e');
    }
  }

}
