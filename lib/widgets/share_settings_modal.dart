import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/document.dart';

import '../providers/documents_provider.dart';
import 'user_selector_modal.dart';

class ShareSettingsModal extends ConsumerStatefulWidget {
  final Document document;

  const ShareSettingsModal({super.key, required this.document});

  @override
  ConsumerState<ShareSettingsModal> createState() => _ShareSettingsModalState();
}

class _ShareSettingsModalState extends ConsumerState<ShareSettingsModal> {
  late bool isDownloadable;
  late bool isScreenshotAllowed;
  late bool isPubliclyShared;
  late List<String> sharedWith;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    isDownloadable = widget.document.isDownloadable;
    isScreenshotAllowed = widget.document.isScreenshotAllowed;
    isPubliclyShared = widget.document.isPubliclyShared;
    sharedWith = List.from(widget.document.sharedWith);
  }

  Future<void> _updateShareSettings() async {
    setState(() {
      isLoading = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('documents')
          .doc(widget.document.id)
          .update({
        'isDownloadable': isDownloadable,
        'isScreenshotAllowed': isScreenshotAllowed,
        'isPubliclyShared': isPubliclyShared,
        'sharedWith': sharedWith,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Share settings updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating share settings: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _showUserSelector() {
    showDialog(
      context: context,
      builder: (context) => UserSelectorModal(
        initialSelectedUserIds: sharedWith,
        onSelectionChanged: (selectedUserIds) {
          setState(() {
            sharedWith = selectedUserIds;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allUsersAsyncValue = ref.watch(allUsersProvider);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Share Settings',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              widget.document.name.isNotEmpty ? widget.document.name : 'Untitled Document',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 20),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Permissions Section
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.security, color: Theme.of(context).colorScheme.primary),
                                const SizedBox(width: 8),
                                const Text(
                                  'Permissions',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            SwitchListTile(
                              title: const Text('Allow Downloads'),
                              subtitle: const Text('Users can download this document'),
                              value: isDownloadable,
                              onChanged: (value) {
                                setState(() {
                                  isDownloadable = value;
                                });
                              },
                            ),
                            SwitchListTile(
                              title: const Text('Allow Screenshots'),
                              subtitle: const Text('Users can take screenshots of this document'),
                              value: isScreenshotAllowed,
                              onChanged: (value) {
                                setState(() {
                                  isScreenshotAllowed = value;
                                });
                              },
                            ),
                            SwitchListTile(
                              title: const Text('Public Sharing'),
                              subtitle: const Text('Anyone with the link can access this document'),
                              value: isPubliclyShared,
                              onChanged: (value) {
                                setState(() {
                                  isPubliclyShared = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Shared Users Section
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.people, color: Theme.of(context).colorScheme.primary),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Shared With',
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                ElevatedButton.icon(
                                  onPressed: _showUserSelector,
                                  icon: const Icon(Icons.person_add, size: 18),
                                  label: const Text('Add Users'),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            
                            if (sharedWith.isEmpty)
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Column(
                                    children: [
                                      Icon(Icons.people_outline, size: 48, color: Colors.grey.shade400),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Not shared with anyone yet',
                                        style: TextStyle(color: Colors.grey.shade600),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Click "Add Users" to share this document',
                                        style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            else
                              allUsersAsyncValue.when(
                                data: (allUsers) {
                                  final sharedUsers = allUsers.where((user) => sharedWith.contains(user.uid)).toList();
                                  
                                  return Column(
                                    children: sharedUsers.map((user) {
                                      return Card(
                                        margin: const EdgeInsets.only(bottom: 8),
                                        child: ListTile(
                                          leading: CircleAvatar(
                                            backgroundColor: Colors.blue.shade100,
                                            child: Text(
                                              (user.displayName?.isNotEmpty == true 
                                                  ? user.displayName![0] 
                                                  : user.email[0]).toUpperCase(),
                                              style: TextStyle(
                                                color: Colors.blue.shade700,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          title: Text(
                                            user.displayName?.isNotEmpty == true 
                                                ? user.displayName! 
                                                : user.email,
                                            style: const TextStyle(fontWeight: FontWeight.w500),
                                          ),
                                          subtitle: user.displayName?.isNotEmpty == true 
                                              ? Text(user.email)
                                              : null,
                                          trailing: IconButton(
                                            icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                                            onPressed: () {
                                              setState(() {
                                                sharedWith.remove(user.uid);
                                              });
                                            },
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  );
                                },
                                loading: () => const Center(child: CircularProgressIndicator()),
                                error: (error, stack) => Text('Error loading users: $error'),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
            
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: isLoading ? null : () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: isLoading ? null : _updateShareSettings,
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save Changes'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 