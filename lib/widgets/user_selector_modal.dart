import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/documents_provider.dart';
import 'package:go_router/go_router.dart';

class UserSelectorModal extends ConsumerStatefulWidget {
  final List<String> initialSelectedUserIds;
  final Function(List<String>) onSelectionChanged;

  const UserSelectorModal({
    super.key,
    required this.initialSelectedUserIds,
    required this.onSelectionChanged,
  });

  @override
  ConsumerState<UserSelectorModal> createState() => _UserSelectorModalState();
}

class _UserSelectorModalState extends ConsumerState<UserSelectorModal> {
  late Set<String> selectedUserIds;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    selectedUserIds = Set.from(widget.initialSelectedUserIds);
  }

  @override
  Widget build(BuildContext context) {
    final allUsersAsyncValue = ref.watch(allUsersProvider);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.9,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select Users to Share With',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                IconButton(
                  onPressed: () => context.pop(),
                  icon: Icon(
                    Icons.close,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Search bar
            TextField(
              decoration: InputDecoration(
                hintText: 'Search users...',
                // FIX: Use withAlpha
                hintStyle: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withAlpha((255 * 0.6).round()),
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    // FIX: Use withAlpha
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withAlpha((255 * 0.3).round()),
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              onChanged: (value) {
                setState(() {
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
                  // FIX: Use withAlpha
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withAlpha((255 * 0.2).round()),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${selectedUserIds.length} user${selectedUserIds.length == 1 ? '' : 's'} selected',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
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
                            // FIX: Use withAlpha
                            color: Theme.of(context).colorScheme.onSurface
                                .withAlpha((255 * 0.4).round()),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            searchQuery.isEmpty
                                ? 'No users found'
                                : 'No users match our search',
                            // FIX: Use withAlpha
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface
                                  .withAlpha((255 * 0.6).round()),
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
                        color: Theme.of(context).colorScheme.surface,
                        child: SizedBox(
                          height:
                              72.0, // Adjust this value as needed for desired height
                          child: CheckboxListTile(
                            value: isSelected,
                            onChanged: (bool? value) {
                              setState(() {
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
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            subtitle:
                                user.displayName?.isNotEmpty == true
                                    ? Text(
                                      user.email,
                                      // FIX: Use withAlpha
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withAlpha((255 * 0.7).round()),
                                      ),
                                    )
                                    : null,
                            secondary: CircleAvatar(
                              // FIX: Use withAlpha
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withAlpha((255 * 0.2).round()),
                              child: Text(
                                (user.displayName?.isNotEmpty == true
                                        ? user.displayName![0]
                                        : user.email[0])
                                    .toUpperCase(),
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            controlAffinity: ListTileControlAffinity.leading,
                          ),
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
                            style: TextStyle(color: Colors.red.shade600),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            error.toString(),
                            style: TextStyle(
                              fontSize: 12,
                              // FIX: Use withAlpha
                              color: Theme.of(context).colorScheme.onSurface
                                  .withAlpha((255 * 0.6).round()),
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
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    widget.onSelectionChanged(selectedUserIds.toList());
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
