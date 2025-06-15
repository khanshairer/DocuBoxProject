import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';
import 'auth_state_provider.dart';

/// Stream provider for all notifications sorted by latest first
final notificationsProvider = StreamProvider<List<AppNotification>>((ref) {
  final user = ref.watch(authStateProvider).currentUser;
  if (user == null) return const Stream.empty();

  final stream = FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('notifications')
      .orderBy('createdAt', descending: true)
      .snapshots();

  return stream.map(
    (snapshot) => snapshot.docs
        .map((doc) => AppNotification.fromFirestore(doc.id, doc.data()))
        .toList(),
  );
});

/// Stream provider for counting unread notifications
final unreadNotificationsCountProvider = StreamProvider<int>((ref) {
  final user = ref.watch(authStateProvider).currentUser;
  if (user == null) return const Stream.empty();

  final stream = FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('notifications')
      .where('read', isEqualTo: false)
      .snapshots();

  return stream.map((snapshot) => snapshot.docs.length);
});
