import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/documents_provider.dart';
import '../providers/auth_state_provider.dart';
import '../models/document.dart';
// CORRECTED IMPORT PATH: Now importing from the consolidated widgets folder
import '../widgets/homepage_menu_bar_widget.dart';
import 'shared_document_viewer_page.dart'; // Assuming this page exists for viewing

class SharedDocumentsPage extends ConsumerWidget {
  const SharedDocumentsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sharedDocumentsAsyncValue = ref.watch(sharedDocumentsStreamProvider);
    final authNotifier = ref.watch(authStateProvider);
    final user = authNotifier.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shared Documents'),
        leading: const BackButton(),
        ),
      // Only show drawer if user is logged in
      drawer: user != null ? HomePageMenuBar() : null,
      body: sharedDocumentsAsyncValue.when(
        data: (documents) {
          if (documents.isEmpty) {
            return _buildEmptyState();
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: documents.length,
            itemBuilder: (context, index) {
              final document = documents[index];
              return SharedDocumentCard(document: document);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) {
          return Center(
            child: Text('Error loading shared documents: ${error.toString()}'),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.share, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 20),
            Text(
              'No shared documents yet!',
              style: TextStyle(
                fontSize: 22,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Documents shared with you will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }
}

// SharedDocumentCard implementation
// NOTE: This should ideally be in its own file like lib/widgets/shared_document_card.dart
// and imported, but kept here as per your provided code for direct modification.
class SharedDocumentCard extends StatelessWidget {
  final Document document;
  const SharedDocumentCard({super.key, required this.document});

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
                    Icons.share,
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
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Shared',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
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
              // FIX: Use Wrap for tags and Spacer for positioning the button
              Row(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .end, // Align contents to the bottom if they wrap
                children: [
                  Expanded(
                    // Use Expanded to give the Wrap space
                    child: Wrap(
                      spacing: 8.0, // Horizontal space between tags
                      runSpacing: 4.0, // Vertical space between lines of tags
                      children: [
                        if (!document.isDownloadable)
                          Container(
                            margin: const EdgeInsets.only(
                              right: 0,
                            ), // Removed right margin as Wrap handles spacing
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'No Download',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.red.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        if (!document.isScreenshotAllowed)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'No Screenshots',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.orange.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Spacer pushes the button to the right
                  Spacer(),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  SharedDocumentViewerPage(document: document),
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
