import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String email;
  final String? displayName;
  final DateTime? createdAt;
  final List<String> fcmTokens;

  AppUser({
    required this.uid,
    required this.email,
    this.displayName,
    this.createdAt,
    this.fcmTokens = const [],
  });

  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw StateError('Missing data for User with ID: ${doc.id}');
    }

    return AppUser(
      uid: doc.id,
      email: data['email'] as String? ?? '',
      displayName: data['displayName'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      fcmTokens: List<String>.from(data['fcmTokens'] ?? []), // Read the tokens, default to an empty list if not present
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'fcmTokens': fcmTokens,
    };
  }
} 