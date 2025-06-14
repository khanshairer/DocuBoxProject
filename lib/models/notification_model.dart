import 'package:cloud_firestore/cloud_firestore.dart';

class AppNotification {
  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool read;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.read,
  });

  factory AppNotification.fromFirestore(String id, Map<String, dynamic> data) {
    return AppNotification(
      id: id,
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      read: data['read'] ?? false,
    );
  }
}
