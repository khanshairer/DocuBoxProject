import 'package:cloud_firestore/cloud_firestore.dart';

class Document {
  final String id;
  final String userId;
  final String name;
  final String type;
  final DateTime expiryDate;
  final String fileName;
  final String downloadUrl;
  final DateTime uploadedAt;
  final List<String> tags; // Added for search functionality and categorization

  Document({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    required this.expiryDate,
    required this.fileName,
    required this.downloadUrl,
    required this.uploadedAt,
    this.tags = const [], // Initialize as an empty list if not provided
  });

  // Factory constructor to create a Document from a Firestore DocumentSnapshot
  factory Document.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?; // Use nullable map
    if (data == null) {
      throw StateError('Missing data for Document with ID: ${doc.id}');
    }

    return Document(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      name: data['name'] as String? ?? 'Untitled',
      type: data['type'] as String? ?? 'Uncategorized',
      // Parse expiry date string (DD/MM/YYYY) into DateTime
      expiryDate: _parseExpiryDate(data['expiry']),
      fileName: data['fileName'] as String? ?? 'No Name',
      downloadUrl: data['downloadUrl'] as String? ?? '',
      uploadedAt: (data['uploadedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      tags: List<String>.from(data['tags'] ?? []), // Ensure tags are parsed as List<String>
    );
  }

  // Helper to parse expiry date from Firestore data (can be Timestamp or String)
  static DateTime _parseExpiryDate(dynamic expiryData) {
    if (expiryData is Timestamp) {
      return expiryData.toDate();
    } else if (expiryData is String) {
      // Handle the case where it might still be a string (from old uploads or manual input)
      try {
        List<String> parts = expiryData.split('/');
        if (parts.length == 3) {
          return DateTime(
            int.parse(parts[2]), // Year
            int.parse(parts[1]), // Month
            int.parse(parts[0]), // Day
          );
        }
      } catch (e) {
        print('Error parsing string date: $expiryData, ${e.toString()}');
      }
    }
    return DateTime.now(); // Default to now if parsing fails
  }

  // Method to convert a Document object to a Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'name': name,
      'type': type,
      'expiry': Timestamp.fromDate(expiryDate), // Always save as Timestamp
      'fileName': fileName,
      'downloadUrl': downloadUrl,
      'uploadedAt': FieldValue.serverTimestamp(),
      'tags': tags, // Include tags in Firestore data
    };
  }
}
