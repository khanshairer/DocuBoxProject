import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/document_model.dart';
import 'document_viewer_page.dart';

class DocumentsListPage extends StatefulWidget {
  const DocumentsListPage({super.key});

  @override
  State<DocumentsListPage> createState() => _DocumentsListPageState();
}

class _DocumentsListPageState extends State<DocumentsListPage> {
  final String? _currentUserId = FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Documents'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: _currentUserId == null
          ? const Center(child: Text('Please log in to view documents'))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('documents')
                  .where('userId', isEqualTo: _currentUserId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final documents = snapshot.data?.docs
                        .map((doc) => Document.fromFirestore(doc))
                        .toList() ??
                    [];
                
                // Sort documents by upload date (newest first)
                documents.sort((a, b) => b.uploadedAt.compareTo(a.uploadedAt));

                if (documents.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.folder_open,
                          size: 80,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No documents yet',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Upload your first document to get started',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: documents.length,
                  itemBuilder: (context, index) {
                    final document = documents[index];
                    return _buildDocumentCard(document);
                  },
                );
              },
            ),
    );
  }

  Widget _buildDocumentCard(Document document) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _getDocumentIcon(document.fileName),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        document.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        document.type,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) => _handleMenuAction(value, document),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'view',
                      child: Row(
                        children: [
                          Icon(Icons.visibility),
                          SizedBox(width: 8),
                          Text('View'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'share',
                      child: Row(
                        children: [
                          Icon(Icons.share),
                          SizedBox(width: 8),
                          Text('Share Link'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'gmail',
                      child: Row(
                        children: [
                          Icon(Icons.email),
                          SizedBox(width: 8),
                          Text('Share via Gmail'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'settings',
                      child: Row(
                        children: [
                          Icon(Icons.settings),
                          SizedBox(width: 8),
                          Text('Sharing Settings'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
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
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  'Expires: ${document.expiry}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const Spacer(),
                Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  _formatDate(document.uploadedAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                if (document.isPubliclyShared)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.link, size: 12, color: Colors.green.shade700),
                        const SizedBox(width: 4),
                        Text(
                          'Shared',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(width: 8),
                if (!document.isDownloadable)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.download_for_offline_outlined, size: 12, color: Colors.orange.shade700),
                        const SizedBox(width: 4),
                        Text(
                          'No Download',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.orange.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(width: 8),
                if (!document.isScreenshotAllowed)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.screenshot_monitor_outlined, size: 12, color: Colors.red.shade700),
                        const SizedBox(width: 4),
                        Text(
                          'No Screenshots',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.red.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _getDocumentIcon(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    IconData iconData;
    Color color;

    switch (extension) {
      case 'pdf':
        iconData = Icons.picture_as_pdf;
        color = Colors.red;
        break;
      case 'doc':
      case 'docx':
        iconData = Icons.description;
        color = Colors.blue;
        break;
      case 'txt':
        iconData = Icons.text_snippet;
        color = Colors.grey;
        break;
      case 'jpg':
      case 'jpeg':
      case 'png':
        iconData = Icons.image;
        color = Colors.green;
        break;
      default:
        iconData = Icons.insert_drive_file;
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(iconData, color: color, size: 24),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _handleMenuAction(String action, Document document) {
    switch (action) {
      case 'view':
        _viewDocument(document);
        break;
      case 'share':
        _shareDocument(document);
        break;
      case 'gmail':
        _shareViaGmail(document);
        break;
      case 'settings':
        _showSharingSettings(document);
        break;
      case 'delete':
        _deleteDocument(document);
        break;
    }
  }

  void _viewDocument(Document document) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DocumentViewerPage(
          document: document,
          isOwner: true,
        ),
      ),
    );
  }

  void _shareDocument(Document document) async {
    if (document.shareId == null) return;

    // Update document to be publicly shared
    await FirebaseFirestore.instance
        .collection('documents')
        .doc(document.id)
        .update({'isPubliclyShared': true});

    final shareUrl = 'https://docubox-app.web.app/shared/${document.shareId}';
    
    await Clipboard.setData(ClipboardData(text: shareUrl));
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Share link copied to clipboard!'),
          backgroundColor: Colors.green,
          action: SnackBarAction(
            label: 'View',
            textColor: Colors.white,
            onPressed: () => _launchUrl(shareUrl),
          ),
        ),
      );
    }
  }

  void _shareViaGmail(Document document) async {
    if (document.shareId == null) return;

    // Update document to be publicly shared
    await FirebaseFirestore.instance
        .collection('documents')
        .doc(document.id)
        .update({'isPubliclyShared': true});

    final shareUrl = 'https://docubox-app.web.app/shared/${document.shareId}';
    final subject = Uri.encodeComponent('Shared Document: ${document.name}');
    final body = Uri.encodeComponent(
      'Hi,\n\nI\'m sharing a document with you: ${document.name}\n\n'
      'Document Type: ${document.type}\n'
      'Expiry Date: ${document.expiry}\n\n'
      'You can view it here: $shareUrl\n\n'
      'Best regards'
    );

    final gmailUrl = 'https://mail.google.com/mail/?view=cm&fs=1&su=$subject&body=$body';
    
    await _launchUrl(gmailUrl);
  }

  void _showSharingSettings(Document document) {
    showDialog(
      context: context,
      builder: (context) => _SharingSettingsDialog(document: document),
    );
  }

  void _deleteDocument(Document document) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Document'),
        content: Text('Are you sure you want to delete "${document.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await FirebaseFirestore.instance
                  .collection('documents')
                  .doc(document.id)
                  .delete();
              
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Document deleted successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open link'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _SharingSettingsDialog extends StatefulWidget {
  final Document document;

  const _SharingSettingsDialog({required this.document});

  @override
  State<_SharingSettingsDialog> createState() => _SharingSettingsDialogState();
}

class _SharingSettingsDialogState extends State<_SharingSettingsDialog> {
  late bool _isDownloadable;
  late bool _isScreenshotAllowed;
  late bool _isPubliclyShared;

  @override
  void initState() {
    super.initState();
    _isDownloadable = widget.document.isDownloadable;
    _isScreenshotAllowed = widget.document.isScreenshotAllowed;
    _isPubliclyShared = widget.document.isPubliclyShared;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Sharing Settings'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SwitchListTile(
            title: const Text('Publicly Shared'),
            subtitle: const Text('Anyone with the link can view'),
            value: _isPubliclyShared,
            onChanged: (value) {
              setState(() {
                _isPubliclyShared = value;
              });
            },
          ),
          SwitchListTile(
            title: const Text('Allow Download'),
            subtitle: const Text('Users can download this document'),
            value: _isDownloadable,
            onChanged: (value) {
              setState(() {
                _isDownloadable = value;
              });
            },
          ),
          SwitchListTile(
            title: const Text('Allow Screenshots'),
            subtitle: const Text('Users can take screenshots'),
            value: _isScreenshotAllowed,
            onChanged: (value) {
              setState(() {
                _isScreenshotAllowed = value;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            await FirebaseFirestore.instance
                .collection('documents')
                .doc(widget.document.id)
                .update({
              'isDownloadable': _isDownloadable,
              'isScreenshotAllowed': _isScreenshotAllowed,
              'isPubliclyShared': _isPubliclyShared,
            });
            
            if (mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Settings updated successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
} 