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
                  data?['username'] ??
                  (data?['email']?.toString().split('@').first ??
                      'Unknown User'),
              'email': data?['email']?.toString() ?? 'No email',
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
    if (!mounted) return;
    final context = this.context;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final batch = FirebaseFirestore.instance.batch();

      final trustedContactRef = FirebaseFirestore.instance
          .collection('users')
          .doc(widget.currentUserId)
          .collection('trustedContacts')
          .doc(contactId);

      final pplTrustURef = FirebaseFirestore.instance
          .collection('users')
          .doc(contactId)
          .collection('pplTrustU')
          .doc(widget.currentUserId);

      final trustedContactExists = (await trustedContactRef.get()).exists;
      final pplTrustUExists = (await pplTrustURef.get()).exists;

      if (trustedContactExists) {
        batch.delete(trustedContactRef);
      }
      if (pplTrustUExists) {
        batch.delete(pplTrustURef);
      }

      await batch.commit();
      await _loadTrustedContacts();
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      debugPrint('Delete error: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to delete contact: ${e.toString()}';
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to delete contact. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _saveTrustedContacts(List<String> contactIds) async {
    if (!mounted) return;
    final context = this.context;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final batch = FirebaseFirestore.instance.batch();
      final contactsRef = FirebaseFirestore.instance
          .collection('users')
          .doc(widget.currentUserId)
          .collection('trustedContacts');

      // Clear existing trusted contacts
      final existing = await contactsRef.get();
      for (var doc in existing.docs) {
        batch.delete(doc.reference);

        // Also remove from their pplTrustU collection
        final pplTrustURef = FirebaseFirestore.instance
            .collection('users')
            .doc(doc.id)
            .collection('pplTrustU')
            .doc(widget.currentUserId);
        batch.delete(pplTrustURef);
      }

      // Add new trusted contacts and update their pplTrustU collections
      for (var userId in contactIds) {
        if (userId == widget.currentUserId) continue; // skip self

        // Add to current user's trustedContacts
        batch.set(contactsRef.doc(userId), {
          'addedAt': FieldValue.serverTimestamp(),
          'userId': userId,
        });

        // Add to other user's pplTrustU
        final trustedByRef = FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('pplTrustU')
            .doc(widget.currentUserId);

        batch.set(trustedByRef, {
          'addedAt': FieldValue.serverTimestamp(),
          'userId': widget.currentUserId,
        });

        // Fetch display name for notification
        final contactDoc =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .get();

        final data = contactDoc.data();
        final contactName =
            data?['displayName'] ??
            data?['username'] ??
            data?['email']?.toString().split('@').first ??
            'Someone';

        await _sendNotification(userId, contactName);
      }

      await batch.commit();
      await _loadTrustedContacts();
      if (!mounted) return;
      Navigator.pop(context); // close loading dialog
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // close loading dialog
      debugPrint('Save error: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to save contacts: ${e.toString()}';
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save contacts. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
            initialSelection: [
              ..._trustedContacts.map((c) => c['id'] as String),
            ],
          ),
    );

    if (selectedContacts != null && mounted) {
      await _saveTrustedContacts(selectedContacts);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trusted Contacts'),
        actions: [
          IconButton(
            onPressed: _showContactSelector,
            icon: const Icon(Icons.add),
          ),
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
              children: const [
                Text(
                  'My Trusted Contacts',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
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
                          title: Text(contact['name'] ?? 'Unknown'),
                          subtitle: Text(contact['email'] ?? 'No email'),
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
  List<Map<String, dynamic>> _filteredUsers = [];
  String? _errorMessage;
  final TextEditingController _searchController = TextEditingController();

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
              final data = doc.data();
              return {
                'id': doc.id,
                'name':
                    data['displayName'] ??
                    data['username'] ??
                    data['email']?.split('@').first ??
                    'Unknown User',
                'email': data['email'] ?? 'No email',
              };
            }).toList();
        _filteredUsers = List.from(_allUsers);
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

  void _filterUsers(String query) {
    setState(() {
      _filteredUsers =
          _allUsers.where((user) {
            final name = user['name']?.toString().toLowerCase() ?? '';
            final email = user['email']?.toString().toLowerCase() ?? '';
            return name.contains(query.toLowerCase()) ||
                email.contains(query.toLowerCase());
          }).toList();
    });
  }

  Widget _buildUserList() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_errorMessage != null) return Center(child: Text(_errorMessage!));
    if (_filteredUsers.isEmpty)
      return const Center(child: Text('No users found'));

    return ListView.builder(
      shrinkWrap: true,
      itemCount: _filteredUsers.length,
      itemBuilder: (context, index) {
        final user = _filteredUsers[index];
        final isSelected = _selectedContacts.contains(user['id']);

        return CheckboxListTile(
          title: Text(user['name'] ?? 'Unknown'),
          subtitle: Text(user['email'] ?? 'No email'),
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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search users...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onChanged: _filterUsers,
              ),
            ),
            Expanded(child: _buildUserList()),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _selectedContacts),
          child: const Text('Save'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
