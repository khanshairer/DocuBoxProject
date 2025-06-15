import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/document.dart';
import 'share_settings_modal.dart';
import '../screens/view_document_page.dart';

class DocumentCard extends StatelessWidget {
  final Document document;

  const DocumentCard({super.key, required this.document});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 120),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.description,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      document.name.isNotEmpty
                          ? document.name
                          : 'Untitled Document',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (value) async {
                      switch (value) {
                        case 'share':
                          showDialog(
                            context: context,
                            builder: (context) => ShareSettingsModal(
                              document: document,
                            ),
                          );
                          break;
                        case 'view':
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ViewDocumentPage(document: document),
                            ),
                          );
                          break;
                        case 'delete':
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Delete Document'),
                              content: const Text('Are you sure you want to delete this document?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(true),
                                  child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );
                          if (confirmed == true) {
                            await FirebaseFirestore.instance
                                .collection('documents')
                                .doc(document.id)
                                .delete();
                          }
                          break;
                      }
                    },
                    itemBuilder: (BuildContext context) => [
                      const PopupMenuItem<String>(
                        value: 'share',
                        child: Row(
                          children: [
                            Icon(Icons.share),
                            SizedBox(width: 8),
                            Text('Share Settings'),
                          ],
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'view',
                        child: Row(
                          children: [
                            Icon(Icons.visibility),
                            SizedBox(width: 8),
                            Text('View Document'),
                          ],
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Type: ${document.type.isNotEmpty ? document.type : 'N/A'}',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 4),
              Text(
                'File: ${document.fileName.isNotEmpty ? document.fileName : 'N/A'}',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 4),
              Text(
                'Expires: ${document.expiryDate.day.toString().padLeft(2, '0')}/${document.expiryDate.month.toString().padLeft(2, '0')}/${document.expiryDate.year}',
                style: TextStyle(
                  fontSize: 14,
                  color:
                  document.expiryDate.isBefore(DateTime.now())
                      ? Colors.red
                      : Colors.green.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.bottomRight,
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ViewDocumentPage(document: document),
                      ),
                    );
                  },
                  icon: const Icon(Icons.visibility),
                  label: const Text('View Document'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
