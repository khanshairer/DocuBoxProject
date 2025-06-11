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
  final List<String> tags;
  final bool isDownloadable;      
  final bool isScreenshotAllowed; 
  final String? shareId;          
  final bool isPubliclyShared;
  final List<String> sharedWith;

  Document({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    required this.expiryDate,
    required this.fileName,
    required this.downloadUrl,
    required this.uploadedAt,
    this.tags = const [],
    this.isDownloadable = true,
    this.isScreenshotAllowed = true,
    this.shareId,
    this.isPubliclyShared = false,
    this.sharedWith = const [],
  });

  // Factory constructor to create a Document from a Firestore DocumentSnapshot
  factory Document.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw StateError('Missing data for Document with ID: ${doc.id}');
    }

    return Document(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      name: data['name'] as String? ?? 'Untitled',
      type: data['type'] as String? ?? 'Uncategorized',
      expiryDate: _parseExpiryDate(data['expiry']),
      fileName: data['fileName'] as String? ?? 'No Name',
      downloadUrl: data['downloadUrl'] as String? ?? '',
      uploadedAt: (data['uploadedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      tags: List<String>.from(data['tags'] ?? []),
      isDownloadable: data['isDownloadable'] as bool? ?? true,
      isScreenshotAllowed: data['isScreenshotAllowed'] as bool? ?? true,
      shareId: data['shareId'] as String?,
      isPubliclyShared: data['isPubliclyShared'] as bool? ?? false,
      sharedWith: List<String>.from(data['sharedWith'] ?? []),
    );
  }

  // Helper to parse expiry date from Firestore data (can be Timestamp or String for backward compatibility)
  static DateTime _parseExpiryDate(dynamic expiryData) {
    if (expiryData is Timestamp) {
      return expiryData.toDate();
    } else if (expiryData is String) {
      try {
        List<String> parts = expiryData.split('/');
        if (parts.length == 3) {
          return DateTime(
            int.parse(parts[2]),
            int.parse(parts[1]),
            int.parse(parts[0]),
          );
        }
      } catch (e) {
        // Fallback for invalid date format, or log using a proper logger if needed for debugging
      }
    }
    return DateTime.now();
  }

  // Method to convert a Document object to a Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'name': name,
      'type': type,
      'expiry': Timestamp.fromDate(expiryDate),
      'fileName': fileName,
      'downloadUrl': downloadUrl,
      'uploadedAt': FieldValue.serverTimestamp(),
      'tags': tags,
      'isDownloadable': isDownloadable,
      'isScreenshotAllowed': isScreenshotAllowed,
      'shareId': shareId,
      'isPubliclyShared': isPubliclyShared,
      'sharedWith': sharedWith,
    };
  }

  // copyWith method
  Document copyWith({
    String? id,
    String? userId,
    String? name,
    String? type,
    DateTime? expiryDate,
    String? fileName,
    String? downloadUrl,
    DateTime? uploadedAt,
    List<String>? tags,
    bool? isDownloadable,
    bool? isScreenshotAllowed,
    String? shareId,
    bool? isPubliclyShared,
    List<String>? sharedWith,
  }) {
    return Document(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      type: type ?? this.type,
      expiryDate: expiryDate ?? this.expiryDate,
      fileName: fileName ?? this.fileName,
      downloadUrl: downloadUrl ?? this.downloadUrl,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      tags: tags ?? this.tags,
      isDownloadable: isDownloadable ?? this.isDownloadable,
      isScreenshotAllowed: isScreenshotAllowed ?? this.isScreenshotAllowed,
      shareId: shareId ?? this.shareId,
      isPubliclyShared: isPubliclyShared ?? this.isPubliclyShared,
      sharedWith: sharedWith ?? this.sharedWith,

    );
  }
}
