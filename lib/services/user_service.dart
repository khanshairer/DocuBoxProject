import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user.dart';

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

  static Future<void> saveUserToken(String token) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return; // Don't proceed if no user is logged in

    try {
      final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

      // Use FieldValue.arrayUnion to add the token to the array.
      // This is great because it only adds the token if it's not already present.
      await userRef.update({
        'fcmTokens': FieldValue.arrayUnion([token]),
      });
    } catch (e) {
      // This can happen if the user document doesn't exist yet.
      // You could add more robust error handling or create the doc if needed.
      print('Error saving user token: $e');
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
}
