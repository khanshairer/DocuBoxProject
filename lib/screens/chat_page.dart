import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

import '../main.dart'; // To access the streamChatClient

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late final StreamChatClient _client;
  fb_auth.User? _firebaseUser;
  bool _isLoading = true;
  List<Map<String, dynamic>> _otherUsers = [];

  @override
  void initState() {
    super.initState();
    _client = streamChatClient;
    _initUserAndLoadContacts();
  }

  Future<void> _initUserAndLoadContacts() async {
    _firebaseUser = fb_auth.FirebaseAuth.instance.currentUser;
    if (_firebaseUser == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      // Connect user to Stream
      await _client.connectUser(
        User(
          id: _firebaseUser!.uid,
          name: _firebaseUser!.displayName ?? 'NoName',
          image:
              (await FirebaseFirestore.instance
                  .collection('users')
                  .doc(_firebaseUser!.uid)
                  .get())['imageUrl'] ??
              '',
        ),
        _client.devToken(_firebaseUser!.uid).rawValue,
      );

      // Attempt to get other users from Firestore
      final snapshot =
          await FirebaseFirestore.instance.collection('users').get();
      _otherUsers =
          snapshot.docs
              .where((doc) => doc.id != _firebaseUser!.uid)
              .map(
                (doc) => {
                  'id': doc.id,
                  'username': doc['username'] ?? 'Unknown',
                  'imageUrl': doc['imageUrl'] ?? '',
                },
              )
              .toList();

      // --- START OF FIX: Add dummy users if no other users are found from Firestore ---
      // This ensures the list is not empty for demonstration purposes.
      if (_otherUsers.isEmpty) {
        debugPrint('No other users found from Firestore. Adding dummy users.');
        _otherUsers.add({
          'id': 'dummyUser1', // This ID must be unique
          'username': 'Alice Smith',
          'imageUrl':
              'https://getstream.io/random_png/img/avatars/user-0.png', // Example image URL
        });
        _otherUsers.add({
          'id': 'dummyUser2', // This ID must be unique
          'username': 'Bob Johnson',
          'imageUrl':
              'https://getstream.io/random_png/img/avatars/user-1.png', // Example image URL
        });
        _otherUsers.add({
          'id': 'dummyUser3', // This ID must be unique
          'username': 'Charlie Brown',
          'imageUrl':
              'https://getstream.io/random_png/img/avatars/user-2.png', // Example image URL
        });
      }
      // --- END OF FIX ---
    } catch (e) {
      debugPrint('Error initializing Stream: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _openChatWithUser(
    String userId,
    String username,
    String imageUrl,
  ) async {
    // Create a new channel for 'messaging' type with the current user and the selected user
    final channel = _client.channel(
      'messaging',
      extraData: {
        'members': [_firebaseUser!.uid, userId],
      },
    );

    // Watch the channel to establish connection and fetch messages
    // This is crucial for Stream Chat to work.
    await channel.watch();

    if (!mounted) return;

    // Navigate to the chat screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => StreamChannel(
              channel: channel,
              child: Scaffold(
                // Use StreamChannelHeader for the chat header
                appBar: StreamChannelHeader(),
                body: Column(
                  children: [
                    // Use StreamMessageListView to display messages
                    Expanded(child: StreamMessageListView()),
                    // Use StreamMessageInput for the message input field
                    StreamMessageInput(),
                  ],
                ),
              ),
            ),
      ),
    );
  }

  @override
  void dispose() {
    // Consider if you need to dispose _client here.
    // If 'streamChatClient' from '../main.dart' is a global singleton,
    // disposing it here might affect other parts of your app that use it.
    // It's generally disposed when the entire application is shut down.
    // _client.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamChat(
      client: _client,
      child: Scaffold(
        appBar: AppBar(title: const Text("Start a Chat")),
        body:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _otherUsers.isEmpty
                ? const Center(child: Text('No other users found'))
                : ListView.builder(
                  itemCount: _otherUsers.length,
                  itemBuilder: (context, index) {
                    final user = _otherUsers[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage:
                            user['imageUrl'].isNotEmpty
                                ? NetworkImage(user['imageUrl'])
                                : null,
                        // If imageUrl is empty, show a default person icon
                        child:
                            user['imageUrl'].isEmpty
                                ? const Icon(Icons.person)
                                : null,
                      ),
                      title: Text(user['username']),
                      onTap:
                          () => _openChatWithUser(
                            user['id'],
                            user['username'],
                            user['imageUrl'],
                          ),
                    );
                  },
                ),
      ),
    );
  }
}
