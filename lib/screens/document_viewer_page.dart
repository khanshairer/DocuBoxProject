import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/document_model.dart';

class DocumentViewerPage extends StatefulWidget {
  final Document document;
  final bool isOwner;

  const DocumentViewerPage({
    super.key,
    required this.document,
    this.isOwner = false,
  });

  @override
  State<DocumentViewerPage> createState() => _DocumentViewerPageState();
}

class _DocumentViewerPageState extends State<DocumentViewerPage>
    with WidgetsBindingObserver {
  bool _isScreenshotBlocked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Block screenshots if not allowed
    if (!widget.document.isScreenshotAllowed && !widget.isOwner) {
      _blockScreenshots();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (_isScreenshotBlocked) {
      _unblockScreenshots();
    }
    super.dispose();
  }

  void _blockScreenshots() {
    // Note: This is a basic implementation. For production apps,
    // you might want to use platform-specific code to prevent screenshots
    setState(() {
      _isScreenshotBlocked = true;
    });
  }

  void _unblockScreenshots() {
    setState(() {
      _isScreenshotBlocked = false;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Additional security: detect when app goes to background
    if (!widget.document.isScreenshotAllowed && !widget.isOwner) {
      if (state == AppLifecycleState.paused) {
        // App is going to background, potential screenshot attempt
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Screenshots are not allowed for this document'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.document.name),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          if (widget.document.isDownloadable || widget.isOwner)
            IconButton(
              onPressed: _downloadDocument,
              icon: const Icon(Icons.download),
              tooltip: 'Download',
            ),
          if (!widget.isOwner)
            IconButton(
              onPressed: _shareDocument,
              icon: const Icon(Icons.share),
              tooltip: 'Share',
            ),
        ],
      ),
      body: Stack(
        children: [
          // Main content
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Document Info Card
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _getDocumentIcon(widget.document.fileName),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.document.name,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.document.type,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 16),
                        
                        // Document Details
                        _buildDetailRow('File Name', widget.document.fileName),
                        _buildDetailRow('Expiry Date', widget.document.expiry),
                        _buildDetailRow('Uploaded', _formatDate(widget.document.uploadedAt)),
                        
                        if (!widget.isOwner) ...[
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 16),
                          
                          // Permissions Info
                          Text(
                            'Permissions',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                widget.document.isDownloadable
                                    ? Icons.download
                                    : Icons.download_for_offline_outlined,
                                size: 16,
                                color: widget.document.isDownloadable
                                    ? Colors.green
                                    : Colors.red,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                widget.document.isDownloadable
                                    ? 'Download allowed'
                                    : 'Download not allowed',
                                style: TextStyle(
                                  color: widget.document.isDownloadable
                                      ? Colors.green.shade700
                                      : Colors.red.shade700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                widget.document.isScreenshotAllowed
                                    ? Icons.screenshot
                                    : Icons.screenshot_monitor_outlined,
                                size: 16,
                                color: widget.document.isScreenshotAllowed
                                    ? Colors.green
                                    : Colors.red,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                widget.document.isScreenshotAllowed
                                    ? 'Screenshots allowed'
                                    : 'Screenshots not allowed',
                                style: TextStyle(
                                  color: widget.document.isScreenshotAllowed
                                      ? Colors.green.shade700
                                      : Colors.red.shade700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Document Preview/View Button
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Icon(
                          Icons.visibility,
                          size: 64,
                          color: Colors.blue.shade600,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'View Document',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Click below to view the document in your browser',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _viewDocument,
                            icon: const Icon(Icons.open_in_browser),
                            label: const Text('Open Document'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade700,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Screenshot blocking overlay
          if (_isScreenshotBlocked)
            Container(
              color: Colors.black.withValues(alpha: 0.1),
              child: const Center(
                child: Text(
                  'Screenshots are disabled for this document',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(iconData, color: color, size: 32),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _viewDocument() async {
    final uri = Uri.parse(widget.document.downloadUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open document'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _downloadDocument() async {
    if (!widget.document.isDownloadable && !widget.isOwner) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Download is not allowed for this document'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final uri = Uri.parse(widget.document.downloadUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Opening download link...'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open download link'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _shareDocument() async {
    if (widget.document.shareId == null) return;

    final shareUrl = 'https://docubox-app.web.app/shared/${widget.document.shareId}';
    await Clipboard.setData(ClipboardData(text: shareUrl));
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Share link copied to clipboard!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
} 