import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class TrustedContact extends StatefulWidget {
  final String currentUserId;

  const TrustedContact({super.key, required this.currentUserId});

  @override
  State<TrustedContact> createState() => _TrustedContactState();
}

class _TrustedContactState extends State<TrustedContact> {
  List<Map<String, dynamic>> _trustedContacts = [];
  bool _isLoading = true;
  String? _errorMessage;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  @override
  void initState() {
    super.initState();
    _loadTrustedContacts();
    _setupNotifications();
  }

  Future<void> _setupNotifications() async {
    await _messaging.requestPermission();
  }

  Future<void> _sendNotification(String userId, String contactName) async {
    try {
      final userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .get();

      final token = userDoc['fcmToken'];
      if (token == null) return;

      // In a real app, you would send this via Cloud Functions
      // This is a simplified version for demonstration
      await FirebaseFirestore.instance
          .collection('notifications')
          .doc(userId)
          .collection('userNotifications')
          .add({
            'title': 'New Trusted Contact',
            'body': '$contactName added you as a trusted contact',
            'timestamp': FieldValue.serverTimestamp(),
            'read': false,
          });
    } catch (e) {
      debugPrint('Error sending notification: $e');
    }
  }

  Future<void> _loadTrustedContacts() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final snapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('trustedContacts')
              .get();

      final contacts = await Future.wait(
        snapshot.docs.map((doc) async {
          try {
            final userDoc =
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(doc.id)
                    .get();

            final data = userDoc.data();
            return {
              'id': doc.id,
              'name':
                  data?['displayName'] ??
                  data?['name'] ??
                  data?['email']?.split('@').first ??
                  'Unknown',
              'email': data?['email'] ?? 'No email',
            };
          } catch (e) {
            debugPrint('Error loading user ${doc.id}: $e');
            return {
              'id': doc.id,
              'name': 'Error loading',
              'email': 'Check console',
            };
          }
        }),
      );

      setState(() {
        _trustedContacts = contacts.where((c) => c['id'] != user.uid).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load contacts: ${e.toString()}';
      });
    }
  }

  Future<void> _deleteContact(String contactId) async {
    try {
      setState(() {
        _isLoading = true;
      });

      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.currentUserId)
          .collection('trustedContacts')
          .doc(contactId)
          .delete();

      await _loadTrustedContacts();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to delete contact: ${e.toString()}';
      });
    }
  }

  Future<void> _saveTrustedContacts(List<String> contactIds) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final batch = FirebaseFirestore.instance.batch();
      final contactsRef = FirebaseFirestore.instance
          .collection('users')
          .doc(widget.currentUserId)
          .collection('trustedContacts');

      // Clear existing
      final existing = await contactsRef.get();
      for (var doc in existing.docs) {
        batch.delete(doc.reference);
      }

      // Add new and send notifications
      for (var userId in contactIds) {
        batch.set(contactsRef.doc(userId), {
          'addedAt': FieldValue.serverTimestamp(),
          'userId': userId,
        });

        // Get contact name for notification
        final contactDoc =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .get();
        final contactName = contactDoc['name'] ?? 'Someone';

        await _sendNotification(userId, contactName);
      }

      await batch.commit();
      await _loadTrustedContacts();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to save contacts: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trusted Contacts'),
        actions: [
          IconButton(
            onPressed: () => context.go('/'),
            icon: const Icon(Icons.home),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Text(
                  'My Trusted Contacts',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _showContactSelector(),
                  child: const Text('Manage Contacts'),
                ),
              ],
            ),
          ),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _trustedContacts.isEmpty
                    ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people_outline, size: 64),
                          SizedBox(height: 16),
                          Text('No trusted contacts yet'),
                          SizedBox(height: 8),
                          Text('Add people you trust to access your documents'),
                        ],
                      ),
                    )
                    : ListView.builder(
                      itemCount: _trustedContacts.length,
                      itemBuilder: (context, index) {
                        if (index >= _trustedContacts.length) {
                          return const SizedBox.shrink();
                        }
                        final contact = _trustedContacts[index];
                        return ListTile(
                          leading: CircleAvatar(
                            child: Text(
                              contact['name'] is String &&
                                      contact['name'].isNotEmpty
                                  ? contact['name'][0]
                                  : '?',
                            ),
                          ),
                          title: Text(contact['name']?.toString() ?? 'Unknown'),
                          subtitle: Text(
                            contact['email']?.toString() ?? 'No email',
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed:
                                () => _showDeleteDialog(
                                  contact['id'],
                                  contact['name'],
                                ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(String contactId, String contactName) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Remove Contact'),
            content: Text('Are you sure you want to remove $contactName?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _deleteContact(contactId);
                },
                child: const Text(
                  'Remove',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  void _showContactSelector() async {
    final selectedContacts = await showDialog<List<String>>(
      context: context,
      builder:
          (context) => ContactSelectorDialog(
            currentUserId: widget.currentUserId,
            initialSelection:
                _trustedContacts.map((c) => c['id'] as String).toList(),
          ),
    );

    if (selectedContacts != null) {
      await _saveTrustedContacts(selectedContacts);
    }
  }
}

class ContactSelectorDialog extends StatefulWidget {
  final String currentUserId;
  final List<String> initialSelection;

  const ContactSelectorDialog({
    super.key,
    required this.currentUserId,
    required this.initialSelection,
  });

  @override
  State<ContactSelectorDialog> createState() => _ContactSelectorDialogState();
}

class _ContactSelectorDialogState extends State<ContactSelectorDialog> {
  late List<String> _selectedContacts;
  bool _isLoading = true;
  List<Map<String, dynamic>> _allUsers = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _selectedContacts = List.from(widget.initialSelection);
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .where(FieldPath.documentId, isNotEqualTo: widget.currentUserId)
              .get();

      setState(() {
        _allUsers =
            snapshot.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return {
                'id': doc.id,
                'name':
                    data['name'] ??
                    data['username'] ??
                    data['email']?.split('@').first ??
                    'Unknown User',
                'email': data['email'] ?? 'No email',
              };
            }).toList();
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load users: ${e.toString()}';
      });
    }
  }

  Widget _buildUserList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(child: Text(_errorMessage!));
    }

    if (_allUsers.isEmpty) {
      return const Center(child: Text('No other users found'));
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: _allUsers.length,
      itemBuilder: (context, index) {
        if (index >= _allUsers.length) {
          return const SizedBox.shrink();
        }
        final user = _allUsers[index];
        final isSelected = _selectedContacts.contains(user['id']);

        return CheckboxListTile(
          title: Text(user['name']?.toString() ?? 'Unknown'),
          subtitle: Text(user['email']?.toString() ?? 'No email'),
          value: isSelected,
          onChanged: (bool? value) {
            setState(() {
              if (value == true) {
                _selectedContacts.add(user['id'] as String);
              } else {
                _selectedContacts.remove(user['id']);
              }
            });
          },
          secondary: CircleAvatar(
            child: Text(
              user['name'] is String && user['name'].isNotEmpty
                  ? user['name'][0]
                  : '?',
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Contacts'),
      content: SizedBox(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height * 0.6,
        child: _buildUserList(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context, _selectedContacts);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
