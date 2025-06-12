import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_state_provider.dart';
import 'document_upload_page.dart'; 
import '../widgets/homepage_menu_bar_widget.dart';
import '../providers/documents_provider.dart';
import '../widgets/document_card.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    ref.read(searchQueryProvider.notifier).state = _searchController.text;
  }

  // Added: Method to navigate to the DocumentUploadPage using GoRouter
  void _navigateToUpload(BuildContext context) {
    context.push('/document-upload'); 
  }

  @override
  Widget build(BuildContext context) {
    final authNotifier = ref.watch(authStateProvider);
    final user = authNotifier.currentUser;
    final documentsAsyncValue = ref.watch(filteredDocumentsProvider);

    // Edited: Added a Scaffold and CircularProgressIndicator for null user
    if (user == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('DocuBox'),
        // Added: AppBar styling properties
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notifications coming soon!')),
              );
            },
            icon: const Icon(Icons.notifications_active),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight + 10),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search documents...',
                // Edited: Added color to prefixIcon
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                suffixIcon:
                    _searchController.text.isNotEmpty
                        ? IconButton(
                          // Edited: Added color to clear icon
                          icon: const Icon(Icons.clear, color: Colors.white70),
                          onPressed: () {
                            _searchController.clear();
                            ref.read(searchQueryProvider.notifier).state = '';
                          },
                        )
                        : null,
                filled: true,
                // Added: fillColor for search bar
                fillColor: Colors.white24,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 16,
                ),
                hintStyle: const TextStyle(color: Colors.white70),
                labelStyle: const TextStyle(color: Colors.white),
              ),
              // Kept: Original cursorColor as requested
              cursorColor: Colors.blue[900],
            ),
          ),
        ),
      ),
      drawer: HomePageMenuBar(authNotifier: authNotifier, currentUser: user),
      // Edited: Wrapped body content in documentsAsyncValue.when for data handling
      body: documentsAsyncValue.when(
        data: (documents) {
          if (documents.isEmpty && _searchController.text.isEmpty) {
            return _buildEmptyState(context);
          } else if (documents.isEmpty && _searchController.text.isNotEmpty) {
            return _buildNoResultsState();
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: documents.length,
            itemBuilder: (context, index) {
              final document = documents[index];
              return DocumentCard(document: document);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) {
          return Center(
            child: Text('Error loading documents: ${error.toString()}'),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        // Edited: Changed context.go to _navigateToUpload method call for consistency
        onPressed: () {
          _navigateToUpload(context); // Use the new method
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 20),
            Text(
              'No documents yet!',
              style: TextStyle(
                fontSize: 22,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Tap the "+" button to upload your first document.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 30),
            // Added: ElevatedButton to the empty state for direct upload
            ElevatedButton.icon(
              onPressed: () => _navigateToUpload(context),
              icon: const Icon(Icons.upload_file),
              label: const Text('Upload Document'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 20),
            Text(
              'No matching documents found.',
              style: TextStyle(
                fontSize: 22,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Try a different search term or check your spelling.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }
}
