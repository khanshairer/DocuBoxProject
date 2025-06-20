import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:badges/badges.dart' as badges;

import '../providers/auth_state_provider.dart';
import '../widgets/homepage_menu_bar_widget.dart';
import '../providers/documents_provider.dart';
import '../widgets/document_card.dart';
import '../services/notification_service.dart';
import '../services/user_service.dart';
import '../providers/notification_settings_provider.dart';
import '../providers/notification_provider.dart';

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
    final enabled = ref.read(notificationEnabledProvider);
    if (enabled) {
      NotificationService.checkAndNotifyExpiringDocuments();
    }
    _setupNotifications();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _setupNotifications() async {
    final notificationService = NotificationService();
    await notificationService.requestPermission();
    final token = await notificationService.getToken();
    if (token != null) {
      await UserService.saveUserToken(token);
    }
  }

  void _onSearchChanged() {
    ref.read(searchQueryProvider.notifier).state = _searchController.text;
  }

  @override
  Widget build(BuildContext context) {
    final authNotifier = ref.watch(authStateProvider);
    final user = authNotifier.currentUser;
    final documentsAsyncValue = ref.watch(filteredDocumentsProvider);

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('DocuBox'),
        actions: [
          Consumer(
            builder: (context, ref, _) {
              final countAsync = ref.watch(unreadNotificationsCountProvider);
              return countAsync.when(
                data: (count) {
                  return IconButton(
                    onPressed: () {
                      context.push('/notifications');
                    },
                    icon: badges.Badge(
                      showBadge: count > 0,
                      badgeContent: Text(
                        count.toString(),
                        style: const TextStyle(
                            color: Colors.white, fontSize: 10),
                      ),
                      child: const Icon(Icons.notifications_active),
                    ),
                  );
                },
                loading: () =>
                    const Icon(Icons.notifications_active),
                error: (_, __) =>
                    const Icon(Icons.notifications_active),
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight + 10),
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
                          ref.read(searchQueryProvider.notifier).state = '';
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white24,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                hintStyle: const TextStyle(color: Colors.white70),
                labelStyle: const TextStyle(color: Colors.white),
              ),
              cursorColor: Colors.blue[900],
            ),
          ),
        ),
      ),
      drawer: const HomePageMenuBar(),
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
        onPressed: () {
          context.push('/document-upload');
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
            ElevatedButton.icon(
              onPressed: () => context.push('/document-upload'),
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
