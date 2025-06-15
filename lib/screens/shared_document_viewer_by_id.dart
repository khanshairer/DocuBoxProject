import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/document.dart';
import 'shared_document_viewer_page.dart';

class SharedDocumentViewerPageById extends StatefulWidget {
  final String documentId;

  const SharedDocumentViewerPageById({super.key, required this.documentId});

  @override
  State<SharedDocumentViewerPageById> createState() => _SharedDocumentViewerPageByIdState();
}

class _SharedDocumentViewerPageByIdState extends State<SharedDocumentViewerPageById> {
  late Future<Document?> _documentFuture;

  @override
  void initState() {
    super.initState();
    _documentFuture = _fetchDocument();
  }

  Future<Document?> _fetchDocument() async {
    final docSnap = await FirebaseFirestore.instance
        .collection('documents')
        .doc(widget.documentId)
        .get();

    if (docSnap.exists) {
      return Document.fromFirestore(docSnap);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Document?>(
      future: _documentFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: const Text("Loading...")),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return Scaffold(
            appBar: AppBar(title: const Text("Error")),
            body: const Center(child: Text('Shared document not found or access denied.')),
          );
        }

        final document = snapshot.data!;
        return SharedDocumentViewerPage(document: document);
      },
    );
  }
}
