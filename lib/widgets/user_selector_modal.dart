import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/documents_provider.dart'; // Our import for documents_provider
import 'package:go_router/go_router.dart';

class UserSelectorModal extends ConsumerStatefulWidget {
  // This is correct, it extends ConsumerStatefulWidget
  final List<String> initialSelectedUserIds;
  final Function(List<String>) onSelectionChanged;

  const UserSelectorModal({
    super.key,
    required this.initialSelectedUserIds,
    required this.onSelectionChanged,
  });

  @override
  // CRITICAL FIX: The state class MUST extend ConsumerState<UserSelectorModal>
  ConsumerState<UserSelectorModal> createState() => _UserSelectorModalState();
}

// CRITICAL FIX: This class definition MUST extend ConsumerState<UserSelectorModal>
class _UserSelectorModalState extends ConsumerState<UserSelectorModal> {
  late Set<String> selectedUserIds;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    selectedUserIds = Set.from(
      widget.initialSelectedUserIds,
    ); // 'widget' is now available
  }

  @override
  Widget build(BuildContext context) {
    // 'ref' is now available because it's a ConsumerState
    final allUsersAsyncValue = ref.watch(allUsersProvider);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Select Users to Share With',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Search bar
            TextField(
              decoration: InputDecoration(
                hintText: 'Search users...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  // 'setState' is now available
                  searchQuery = value.toLowerCase();
                });
              },
            ),
            const SizedBox(height: 16),

            // Selected count
            if (selectedUserIds.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${selectedUserIds.length} user${selectedUserIds.length == 1 ? '' : 's'} selected',
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(height: 16),

            // Users list
            Expanded(
              child: allUsersAsyncValue.when(
                data: (users) {
                  final filteredUsers =
                      users.where((user) {
                        if (searchQuery.isEmpty) return true;
                        return user.email.toLowerCase().contains(searchQuery) ||
                            (user.displayName?.toLowerCase().contains(
                                  searchQuery,
                                ) ??
                                false);
                      }).toList();

                  if (filteredUsers.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            searchQuery.isEmpty
                                ? 'No users found'
                                : 'No users match our search',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = filteredUsers[index];
                      final isSelected = selectedUserIds.contains(user.uid);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: CheckboxListTile(
                          value: isSelected,
                          onChanged: (bool? value) {
                            setState(() {
                              // 'setState' is now available
                              if (value == true) {
                                selectedUserIds.add(user.uid);
                              } else {
                                selectedUserIds.remove(user.uid);
                              }
                            });
                          },
                          title: Text(
                            user.displayName?.isNotEmpty == true
                                ? user.displayName!
                                : user.email,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          subtitle:
                              user.displayName?.isNotEmpty == true
                                  ? Text(user.email)
                                  : null,
                          secondary: CircleAvatar(
                            backgroundColor: Colors.blue.shade100,
                            child: Text(
                              (user.displayName?.isNotEmpty == true
                                      ? user.displayName![0]
                                      : user.email[0])
                                  .toUpperCase(),
                              style: TextStyle(
                                color: Colors.blue.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error:
                    (error, stack) => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error loading users',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.red.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            error.toString(),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
              ),
            ),

            const SizedBox(height: 16),

            // Our Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    widget.onSelectionChanged(
                      selectedUserIds.toList(),
                    ); // 'widget' is now available
                    Navigator.of(context).pop();
                  },
                  child: const Text('Apply Selection'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
