import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SeeTrustedDocumentsPage extends StatefulWidget {
  final String currentUserId;

  const SeeTrustedDocumentsPage({super.key, required this.currentUserId});

  @override
  State<SeeTrustedDocumentsPage> createState() =>
      _SeeTrustedDocumentsPageState();
}

class _SeeTrustedDocumentsPageState extends State<SeeTrustedDocumentsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Stream<QuerySnapshot> _trustedContactsStream;
  final Map<String, List<DocumentSnapshot>> _userDocuments = {};
  final Set<String> _expandedUsers = {};

  @override
  void initState() {
    super.initState();
    _trustedContactsStream =
        _firestore
            .collection('users')
            .doc(widget.currentUserId)
            .collection('pplTrustU')
            .snapshots();
  }

  Future<void> _fetchUserDocuments(String userId) async {
    if (_userDocuments.containsKey(userId)) return;

    try {
      // Changed to fetch ALL documents by this user, not just shared ones
      final docs =
          await _firestore
              .collection('documents')
              .where('userId', isEqualTo: userId)
              .get();

      if (mounted) {
        setState(() => _userDocuments[userId] = docs.docs);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _userDocuments[userId] = []; // Empty list if error occurs
        });
      }
    }
  }

  String _getUserName(DocumentSnapshot userDoc) {
    final data = userDoc.data() as Map<String, dynamic>?;
    return data?['displayName'] ??
        data?['username'] ??
        data?['email']?.toString().split('@').first ??
        'Unknown User';
  }

  String _getUserEmail(DocumentSnapshot userDoc) {
    final data = userDoc.data() as Map<String, dynamic>?;
    return data?['email']?.toString() ?? 'No email';
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withAlpha(128),
          ),
          const SizedBox(height: 16),
          Text(
            'No Trusted Connections',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'People who add you as a trusted contact will appear here',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentItem(BuildContext context, DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ListTile(
      leading: _getDocumentIcon(data['type']),
      title: Text(data['name']?.toString() ?? 'Untitled Document'),
      subtitle: Text(
        'Uploaded: ${data['uploadedAt']?.toDate().toString() ?? 'Unknown date'}',
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: IconButton(
        icon: const Icon(Icons.open_in_new),
        onPressed: () => _openDocument(context, doc.id, data),
      ),
    );
  }

  Icon _getDocumentIcon(String? type) {
    switch (type?.toLowerCase()) {
      case 'pdf':
        return const Icon(Icons.picture_as_pdf, color: Colors.red);
      case 'image':
        return const Icon(Icons.image, color: Colors.blue);
      case 'word':
        return const Icon(Icons.description, color: Colors.blue);
      default:
        return const Icon(Icons.insert_drive_file);
    }
  }

  void _openDocument(
    BuildContext context,
    String docId,
    Map<String, dynamic> data,
  ) {
    context.push(
      '/shared-document-view',
      extra: {'documentId': docId, 'documentData': data},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trusted Documents'),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () => context.go('/'),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _trustedContactsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error loading contacts'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyState(context);
          }

          final contacts = snapshot.data!.docs;

          return ListView.builder(
            itemCount: contacts.length,
            itemBuilder: (context, index) {
              final contact = contacts[index];
              final userId = contact.id;

              return FutureBuilder<DocumentSnapshot>(
                future: _firestore.collection('users').doc(userId).get(),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return const ListTile(
                      leading: CircleAvatar(child: CircularProgressIndicator()),
                      title: Text('Loading user...'),
                    );
                  }

                  if (userSnapshot.hasError || !userSnapshot.hasData) {
                    return ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.error)),
                      title: const Text('Error loading user'),
                      subtitle: Text('ID: $userId'),
                    );
                  }

                  final userDoc = userSnapshot.data!;
                  final userName = _getUserName(userDoc);
                  final userEmail = _getUserEmail(userDoc);

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: ExpansionTile(
                      initiallyExpanded: _expandedUsers.contains(userId),
                      onExpansionChanged: (expanded) {
                        if (mounted) {
                          setState(() {
                            if (expanded) {
                              _expandedUsers.add(userId);
                              _fetchUserDocuments(userId);
                            } else {
                              _expandedUsers.remove(userId);
                            }
                          });
                        }
                      },
                      leading: CircleAvatar(
                        child: Text(userName.isNotEmpty ? userName[0] : '?'),
                      ),
                      title: Text(userName),
                      subtitle: Text(userEmail),
                      children: [
                        if (_userDocuments[userId] == null)
                          const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        else if (_userDocuments[userId]!.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text('No documents found for this user'),
                          )
                        else
                          Column(
                            children:
                                _userDocuments[userId]!
                                    .map(
                                      (doc) => _buildDocumentItem(context, doc),
                                    )
                                    .toList(),
                          ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
