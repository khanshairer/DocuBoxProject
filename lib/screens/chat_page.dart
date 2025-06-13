import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    // In a real application, this would send the message to a backend (e.g., Firestore).
    // For this simple representation, we'll just clear the text field and print to console.
    if (_messageController.text.isNotEmpty) {
      _messageController.clear();
      // You would typically add the message to a list here and update state
      // to display it in the chat area.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        backgroundColor:
            Theme.of(context).colorScheme.primary, // Using theme color
        foregroundColor:
            Theme.of(
              context,
            ).colorScheme.onPrimary, // Text color that contrasts
      ),
      body: Column(
        children: [
          // Expanded area for displaying messages
          Expanded(
            child: Center(
              child: Text(
                'No messages yet. Start chatting!',
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withAlpha((255 * 0.6).round()),
                  fontSize: 16,
                ),
              ),
            ),
            // In a real app, this would be a ListView.builder or similar
            // that displays a list of ChatBubble widgets.
            // For example:
            // child: ListView.builder(
            //   itemCount: _messages.length,
            //   itemBuilder: (context, index) {
            //     return ChatBubble(message: _messages[index]);
            //   },
            // ),
          ),
          // Input field for typing messages
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      hintStyle: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withAlpha((255 * 0.5).round()),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: BorderSide(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withAlpha((255 * 0.7).round()),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.secondary,
                          width: 2,
                        ),
                      ),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    onSubmitted:
                        (_) =>
                            _sendMessage(), // Allows sending on keyboard enter
                  ),
                ),
                const SizedBox(width: 8.0),
                FloatingActionButton(
                  onPressed: _sendMessage,
                  mini: true,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
