// chat_history.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatHistoryScreen extends StatefulWidget {
  final Map<String, dynamic> contact;

  ChatHistoryScreen({required this.contact});

  @override
  _ChatHistoryScreenState createState() => _ChatHistoryScreenState();
}

class _ChatHistoryScreenState extends State<ChatHistoryScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final TextEditingController _messageController = TextEditingController();

  List<Map<String, dynamic>> messages = [];

  @override
  void initState() {
    super.initState();
    _fetchChatHistory();
  }

  Future<void> _fetchChatHistory() async {
    QuerySnapshot querySnapshot = await _firestore
        .collection('chat_history')
        .doc(_auth.currentUser!.uid)
        .collection(widget.contact['uid'])
        .orderBy('timestamp', descending: true)
        .get();

    setState(() {
      messages = querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    });
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      var message = {
        'text': _messageController.text,
        'senderId': _auth.currentUser!.uid,
        'timestamp': Timestamp.now(),
      };

      // Storing the message in Firestore.
      await _firestore
          .collection('chat_history')
          .doc(_auth.currentUser!.uid)
          .collection(widget.contact['uid'])
          .add(message);

      // Optionally, clear the message input field.
      _messageController.clear();

      // Refresh the chat history to display the new message.
      _fetchChatHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.contact['displayName'] ?? 'Chat'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true, // New messages appear at the bottom
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(messages[index]['text']),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "Enter your message...",
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
