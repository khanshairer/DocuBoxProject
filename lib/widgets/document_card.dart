import 'package:flutter/material.dart';
import '../models/document.dart';
import 'share_settings_modal.dart';
import '../screens/view_document_page.dart';
// You'll need to create this service
import '../services/document_conversion_service.dart';

class DocumentCard extends StatelessWidget {
  final Document document;

  const DocumentCard({super.key, required this.document});

  // Determine available conversion options based on file type
  List<String> _getConversionOptions(String fileType) {
    switch (fileType.toLowerCase()) {
      case 'pdf':
        return ['JPG', 'PNG'];
      case 'jpg':
      case 'jpeg':
        return ['PDF', 'PNG'];
      case 'png':
        return ['PDF', 'JPG'];
      case 'doc':
      case 'docx':
        return ['PDF'];
      case 'txt':
        return ['PDF'];
      default:
        return [];
    }
  }

  String _getFileExtension(String fileName) {
    if (fileName.isEmpty) return '';
    final parts = fileName.split('.');
    if (parts.length > 1) {
      return parts.last.toLowerCase();
    }
    return '';
  }

  void _showConversionDialog(BuildContext context) {
    final fileExtension = _getFileExtension(document.fileName);
    final conversionOptions = _getConversionOptions(fileExtension);

    if (conversionOptions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No conversion options available for this file type'),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Convert Document'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Convert ${document.name} to:'),
              const SizedBox(height: 16),
              ...conversionOptions.map((format) => ListTile(
                    title: Text(format),
                    leading: Icon(
                      _getFormatIcon(format),
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      _convertDocument(context, format);
                    },
                  )),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  IconData _getFormatIcon(String format) {
    switch (format.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image;
      default:
        return Icons.file_copy;
    }
  }

  void _convertDocument(BuildContext context, String targetFormat) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Converting document...'),
                ],
              ),
            ),
          ),
        );
      },
    );

    try {
      // Call your conversion service
      final conversionService = DocumentConversionService();
      final result = await conversionService.convertDocument(
        document: document,
        targetFormat: targetFormat.toLowerCase(),
      );

      // Close loading dialog
      Navigator.of(context).pop();

      if (result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Document converted to $targetFormat successfully!'),
            action: SnackBarAction(
              label: 'View',
              onPressed: () {
                // Navigate to view the converted document
                // You might need to refresh the document list or navigate to the new document
              },
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Conversion failed: ${result.error}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Close loading dialog
      Navigator.of(context).pop();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error converting document: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final fileExtension = _getFileExtension(document.fileName);
    final hasConversionOptions = _getConversionOptions(fileExtension).isNotEmpty;

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
                    onSelected: (value) {
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
                        case 'convert':
                          _showConversionDialog(context);
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
                      if (hasConversionOptions)
                        const PopupMenuItem<String>(
                          value: 'convert',
                          child: Row(
                            children: [
                              Icon(Icons.transform),
                              SizedBox(width: 8),
                              Text('Convert To'),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (hasConversionOptions) ...[
                    TextButton.icon(
                      onPressed: () => _showConversionDialog(context),
                      icon: const Icon(Icons.transform, size: 20),
                      label: const Text('Convert'),
                      style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  TextButton.icon(
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
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}