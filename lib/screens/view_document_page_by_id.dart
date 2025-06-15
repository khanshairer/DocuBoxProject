import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/document.dart';
import 'view_document_page.dart';

class ViewDocumentPageById extends StatelessWidget {
  final String documentId;

  const ViewDocumentPageById({super.key, required this.documentId});

  Future<Document?> _fetchDocument() async {
    final docSnap = await FirebaseFirestore.instance
        .collection('documents')
        .doc(documentId)
        .get();

    if (docSnap.exists) {
      return Document.fromFirestore(docSnap);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Document?>(
      future: _fetchDocument(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: const Text("Loading Document")),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return Scaffold(
            appBar: AppBar(title: const Text("Not Found")),
            body: const Center(child: Text('Document not found or access denied.')),
          );
        }

        return ViewDocumentPage(document: snapshot.data!);
      },
    );
  }
}
