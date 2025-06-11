import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/document.dart';

// Provider for the current search query
final searchQueryProvider = StateProvider<String>((ref) => '');

// StreamProvider that fetches all documents for the current user
// and provides a list of Documents.
final allDocumentsStreamProvider = StreamProvider.autoDispose<List<Document>>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    return Stream.value([]);
  }

  return FirebaseFirestore.instance
      .collection('documents')
      .where('userId', isEqualTo: user.uid)
      .orderBy('uploadedAt', descending: true)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) => Document.fromFirestore(doc)).toList();
      })
      .handleError((error) {
        // Consider using a proper logging solution like 'logger' package
        // for production errors instead of just printing.
        return <Document>[];
      });
});

// Filtered documents provider based on search query
final filteredDocumentsProvider = StreamProvider.autoDispose<List<Document>>((ref) {
  final allDocumentsAsyncValue = ref.watch(allDocumentsStreamProvider);
  final searchQuery = ref.watch(searchQueryProvider);

  return allDocumentsAsyncValue.when(
    data: (documents) {
      if (searchQuery.isEmpty) {
        return Stream.value(documents);
      }

      final lowerCaseQuery = searchQuery.toLowerCase();
      final filteredList = documents.where((doc) {
        return (doc.name).toLowerCase().contains(lowerCaseQuery) ||
               (doc.type).toLowerCase().contains(lowerCaseQuery) ||
               (doc.fileName).toLowerCase().contains(lowerCaseQuery) ||
               doc.tags.any((tag) => tag.toLowerCase().contains(lowerCaseQuery));
      }).toList();
      return Stream.value(filteredList);
    },
    loading: () => Stream.value([]),
    error: (err, stack) {
      // Consider using a proper logging solution for errors
      return Stream.value([]);
    },
  );
});
