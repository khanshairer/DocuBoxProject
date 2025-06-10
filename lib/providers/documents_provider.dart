import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/document.dart'; // Import the Document model

// Provider for the current search query
final searchQueryProvider = StateProvider<String>((ref) => '');

// StreamProvider that fetches all documents for the current user
// and provides a list of Documents.
final allDocumentsStreamProvider = StreamProvider.autoDispose<List<Document>>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    print('DEBUG: allDocumentsStreamProvider - No authenticated user. Returning empty stream.');
    return Stream.value([]); // No user, no documents
  }

  print('DEBUG: allDocumentsStreamProvider - Fetching documents for UID: ${user.uid}');

  // Listen to Firestore changes for documents uploaded by the current user
  return FirebaseFirestore.instance
      .collection('documents')
      .where('userId', isEqualTo: user.uid) // Filter by user ID
      .orderBy('uploadedAt', descending: true) // Order by latest upload
      .snapshots()
      .map((snapshot) {
        print('DEBUG: allDocumentsStreamProvider - Received ${snapshot.docs.length} documents from Firestore.');
        return snapshot.docs.map((doc) => Document.fromFirestore(doc)).toList();
      })
      .handleError((error) {
        print('ERROR: allDocumentsStreamProvider - Firestore stream error: $error');
        // Optionally, rethrow the error or provide a default value
        return <Document>[]; // Return empty list on error
      });
});

// Filtered documents provider based on search query
final filteredDocumentsProvider = StreamProvider.autoDispose<List<Document>>((ref) {
  // Watch the stream of all documents
  final allDocumentsAsyncValue = ref.watch(allDocumentsStreamProvider);
  // Watch the current search query
  final searchQuery = ref.watch(searchQueryProvider);

  return allDocumentsAsyncValue.when(
    data: (documents) {
      print('DEBUG: filteredDocumentsProvider - Processing ${documents.length} documents for search query: "$searchQuery"');
      // If there's no search query, return all documents
      if (searchQuery.isEmpty) {
        return Stream.value(documents);
      }

      // Otherwise, filter the documents based on the search query
      final lowerCaseQuery = searchQuery.toLowerCase();
      final filteredList = documents.where((doc) {
        // Ensure all fields are null-safe before calling .toLowerCase()
        return (doc.name).toLowerCase().contains(lowerCaseQuery) ||
               (doc.type).toLowerCase().contains(lowerCaseQuery) ||
               (doc.fileName).toLowerCase().contains(lowerCaseQuery) ||
               doc.tags.any((tag) => tag.toLowerCase().contains(lowerCaseQuery));
      }).toList();
      print('DEBUG: filteredDocumentsProvider - Filtered down to ${filteredList.length} documents.');
      return Stream.value(filteredList);
    },
    loading: () {
      print('DEBUG: filteredDocumentsProvider - Loading documents...');
      return Stream.value([]); // Return empty list while loading
    },
    error: (err, stack) {
      print('ERROR: filteredDocumentsProvider - Error fetching documents: $err');
      return Stream.value([]); // Return empty list on error
    },
  );
});
