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

  Stream<QuerySnapshot> get chatMessagesStream {
    return _firestore
        .collection('chat_history')
        .doc(_auth.currentUser!.uid)
        .collection(widget.contact['uid'])
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      var message = {
        'text': _messageController.text,
        'senderId': _auth.currentUser!.uid,
        'timestamp': Timestamp.now(),
      };

      // Storing the message for the sender
      await _firestore
          .collection('chat_history')
          .doc(_auth.currentUser!.uid)
          .collection(widget.contact['uid'])
          .add(message);

      // Storing the message for the recipient
      await _firestore
          .collection('chat_history')
          .doc(widget.contact['uid'])
          .collection(_auth.currentUser!.uid)
          .add(message);

      _messageController.clear();
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
            child: StreamBuilder<QuerySnapshot>(
              stream: chatMessagesStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                final messages = snapshot.data!.docs
                    .map((doc) => doc.data() as Map<String, dynamic>)
                    .toList();
                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(messages[index]['text']),
                    );
                  },
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
