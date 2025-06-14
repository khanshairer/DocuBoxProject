import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';
import 'auth_state_provider.dart';

final notificationsProvider = StreamProvider<List<AppNotification>>((ref) {
  final user = ref.watch(authStateProvider).currentUser;
  if (user == null) return const Stream.empty();

  final stream = FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('notifications')
      .orderBy('createdAt', descending: true)
      .snapshots();

  return stream.map((snapshot) => snapshot.docs
      .map((doc) => AppNotification.fromFirestore(doc.id, doc.data()))
      .toList());
});
