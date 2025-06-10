import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_state_provider.dart'; // Import your auth state provider
import 'upload_page_ajseby/document_upload_page.dart'; // Import by ajseby
import '../widget/homepage_menu_bar_widget.dart';
import '../models/document.dart'; // IMPORTANT: Import your Document model
import '../providers/documents_provider.dart'; // IMPORTANT: Import your documents provider

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  // Controller for the search text field
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Add a listener to the search controller to update the search query provider
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  // This method updates the searchQueryProvider in Riverpod whenever the text changes
  void _onSearchChanged() {
    // We use ref.read (not ref.watch) here because we are inside a listener
    // and only want to modify the state, not rebuild the widget based on it.
    ref.read(searchQueryProvider.notifier).state = _searchController.text;
  }

  // Navigate to the document upload page
  void _navigateToUpload(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const DocumentUploadPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch the authStateProvider to get the FirebaseAuthStateNotifier instance.
    final authNotifier = ref.watch(authStateProvider);
    final user = authNotifier.currentUser;

    // Watch the filteredDocumentsProvider to get the list of documents.
    // This will react to both Firebase data changes and search query changes.
    final documentsAsyncValue = ref.watch(filteredDocumentsProvider);

    // Show a loading indicator or placeholder if user is not yet loaded (though GoRouter handles this largely)
    if (user == null) {
      print('DEBUG: HomePage - User is null, showing CircularProgressIndicator.');
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    // Print the current user's UID for debugging purposes
    print('DEBUG: HomePage - Currently logged-in user UID: ${user.uid}');

    return Scaffold(
      appBar: AppBar(
        title: const Text('DocuBox'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          // Notification icon button
          IconButton(onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Notifications coming soon!')),
            );
          }, icon: const Icon(Icons.notifications_active)),
        ],
        // AppBar bottom section for the search bar
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight + 10), // Height for search bar
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search documents...',
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white70),
                        onPressed: () {
                          _searchController.clear();
                          // Clear the Riverpod state for search query
                          ref.read(searchQueryProvider.notifier).state = ''; 
                        },
                      )
                    : null, // No clear icon if search is empty
                filled: true,
                fillColor: Colors.white24, // Slightly transparent white for AppBar background
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none, // No border needed when filled
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                hintStyle: const TextStyle(color: Colors.white70),
                labelStyle: const TextStyle(color: Colors.white),
              ),
              style: const TextStyle(color: Colors.white, fontSize: 16),
              cursorColor: Colors.white, // Custom cursor color
            ),
          ),
        ),
      ),
      // Drawer for navigation menu
      drawer: HomePageMenuBar(authNotifier: authNotifier, currentUser: user),
      // Main body content to display documents
      body: documentsAsyncValue.when(
        data: (documents) {
          print('DEBUG: HomePage - Rendered ${documents.length} documents.');
          // If no documents and no search query, show empty state
          if (documents.isEmpty && _searchController.text.isEmpty) {
            return _buildEmptyState(context); 
          } 
          // If search query is present but no results found
          else if (documents.isEmpty && _searchController.text.isNotEmpty) {
            return _buildNoResultsState(); 
          }
          // Otherwise, display the list of documents
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: documents.length,
            itemBuilder: (context, index) {
              final document = documents[index];
              // Print each document's UID for comparison
              print('DEBUG: HomePage - Document #${index} UID: ${document.userId}');
              return DocumentCard(document: document); // Custom widget to display each document
            },
          );
        },
        // Show loading indicator while documents are being fetched
        loading: () {
          print('DEBUG: HomePage - Documents loading...');
          return const Center(child: CircularProgressIndicator());
        },
        // Show error message if fetching fails
        error: (error, stack) {
          print('ERROR: HomePage - Documents loading error: ${error.toString()}');
          return Center(
            child: Text('Error loading documents: ${error.toString()}'),
          );
        },
      ),
      // Floating Action Button to navigate to upload page
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToUpload(context),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        child: const Icon(Icons.add),
      ),
    );
  }

  // Helper widget for when there are no documents yet
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: SingleChildScrollView( // Added to prevent overflow on smaller screens
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 20),
            Text(
              'No documents yet!',
              style: TextStyle(fontSize: 22, color: Colors.grey.shade600, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Tap the "+" button to upload your first document.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 30),
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

  // Helper widget for when search yields no results
  Widget _buildNoResultsState() {
    return Center(
      child: SingleChildScrollView( // Added to prevent overflow on smaller screens
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 20),
            Text(
              'No matching documents found.',
              style: TextStyle(fontSize: 22, color: Colors.grey.shade600, fontWeight: FontWeight.bold),
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

// A simple widget to display a single document card
// This can be extracted into its own file (e.g., lib/widgets/document_card.dart)
class DocumentCard extends StatelessWidget {
  final Document document;

  const DocumentCard({super.key, required this.document});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.description, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    document.name,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // TODO: Add options button for edit/delete/share
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () {
                    // Implement options menu
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Document options coming soon!')),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Type: ${document.type}',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 4),
            Text(
              'File: ${document.fileName}',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 4),
            Text(
              'Expires: ${document.expiryDate.day.toString().padLeft(2, '0')}/${document.expiryDate.month.toString().padLeft(2, '0')}/${document.expiryDate.year}',
              style: TextStyle(
                fontSize: 14,
                // Highlight expired documents in red
                color: document.expiryDate.isBefore(DateTime.now()) ? Colors.red : Colors.green.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
            // TODO: Add a button to view/preview the document (PDF preview core feature)
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.bottomRight,
              child: TextButton.icon(
                onPressed: () {
                  // This is where you would navigate to your PDF viewer page
                  // For now, it's a placeholder.
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Viewing ${document.name} coming soon!')),
                  );
                },
                icon: const Icon(Icons.visibility),
                label: const Text('View Document'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
