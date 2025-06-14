import 'package:flutter/material.dart';
import '../models/document.dart';
import 'share_settings_modal.dart';
import '../screens/view_document_page.dart';
import '../services/document_conversion_service.dart';

class DocumentCard extends StatelessWidget {
  final Document document;

  const DocumentCard({Key? key, required this.document}) : super(key: key);

  /// Defines valid conversion operations:
  /// - DOC/DOCX → PDF
  /// - PNG → JPG
  /// - JPG/JPEG → PNG
  List<String> _getConversionOptions(String fileType) {
    switch (fileType.toLowerCase()) {
      case 'doc':
      case 'docx':
        return ['PDF'];
      case 'png':
        return ['JPG'];
      case 'jpg':
      case 'jpeg':
        return ['PNG'];
      default:
        return [];
    }
  }

  /// Extracts the file extension (e.g. 'pdf', 'docx')
  String _getFileExtension(String fileName) {
    if (fileName.isEmpty) return '';
    final parts = fileName.split('.');
    return parts.length > 1 ? parts.last.toLowerCase() : '';
  }

  /// Dialog to choose a conversion format
  void _showConversionDialog(BuildContext context) {
    final ext = _getFileExtension(document.fileName);
    final options = _getConversionOptions(ext);
    if (options.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('No conversion options available')));
      return;
    }
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Convert Document'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Convert ${document.name} to:'),
            const SizedBox(height: 16),
            ...options.map((fmt) => ListTile(
              leading: Icon(
                fmt == 'PDF' ? Icons.picture_as_pdf : Icons.image,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: Text(fmt),
              onTap: () {
                Navigator.of(context).pop();
                _convertDocument(context, fmt);
              },
            )),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel'))
        ],
      ),
    );
  }

  /// Performs conversion and displays a spinner + result
  void _convertDocument(BuildContext context, String targetFormat) async {
    final messenger = ScaffoldMessenger.of(context);
    final rootNav = Navigator.of(context, rootNavigator: true);
    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (_) => const Center(
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
      ),
    );

    ConversionResult result;
    try {
      result = await DocumentConversionService().convertDocument(
        document: document,
        targetFormat: targetFormat.toLowerCase(),
      );
    } catch (e) {
      result = ConversionResult(success: false, error: e.toString());
    } finally {
      rootNav.pop();
    }

    if (result.success) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Converted to $targetFormat!'),
          action: SnackBarAction(label: 'View', onPressed: () {}),
        ),
      );
    } else {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Conversion failed: ${result.error}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ext = _getFileExtension(document.fileName);
    final hasOptions = _getConversionOptions(ext).isNotEmpty;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 150),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.description, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          document.name.isNotEmpty ? document.name : 'Untitled Document',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          ext.toUpperCase(),
                          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (value) {
                      switch (value) {
                        case 'share':
                          showDialog(
                            context: context,
                            builder: (_) => ShareSettingsModal(document: document),
                          );
                          break;
                        case 'view':
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => ViewDocumentPage(document: document)),
                          );
                          break;
                        case 'convert':
                          _showConversionDialog(context);
                          break;
                      }
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(value: 'share', child: Row(children: [Icon(Icons.share), SizedBox(width: 8), Text('Share Settings')])),
                      const PopupMenuItem(value: 'view', child: Row(children: [Icon(Icons.visibility), SizedBox(width: 8), Text('View Document')])),
                      if (hasOptions)
                        const PopupMenuItem(value: 'convert', child: Row(children: [Icon(Icons.transform), SizedBox(width: 8), Text('Convert To')])),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (hasOptions) ...[
                    TextButton.icon(
                      onPressed: () => _showConversionDialog(context),
                      icon: const Icon(Icons.transform, size: 16),
                      label: const Text('Convert', style: TextStyle(fontSize: 12)),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        foregroundColor: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  TextButton.icon(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => ViewDocumentPage(document: document)),
                    ),
                    icon: const Icon(Icons.visibility, size: 16),
                    label: const Text('View', style: TextStyle(fontSize: 12)),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
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
