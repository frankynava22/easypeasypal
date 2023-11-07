import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'font_size_notifier.dart'; // Import FontSizeNotifier

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
  final Set<String> _selectedMessageIds = Set();

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

  Future<void> _deleteSelectedMessages() async {
    for (String id in _selectedMessageIds) {
      // Delete for the sender
      await _firestore
          .collection('chat_history')
          .doc(_auth.currentUser!.uid)
          .collection(widget.contact['uid'])
          .doc(id)
          .delete();

      // Delete for the recipient
      await _firestore
          .collection('chat_history')
          .doc(widget.contact['uid'])
          .collection(_auth.currentUser!.uid)
          .doc(id)
          .delete();
    }
    _selectedMessageIds.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final fontSizeNotifier = Provider.of<FontSizeNotifier>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.contact['displayName'] ?? 'Chat',
            style: TextStyle(fontSize: fontSizeNotifier.fontSize)),
        actions: _selectedMessageIds.isNotEmpty
            ? [
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: _deleteSelectedMessages,
                )
              ]
            : [],
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
                    bool isCurrentUser =
                        messages[index]['senderId'] == _auth.currentUser!.uid;
                    bool isSelected = _selectedMessageIds
                        .contains(snapshot.data!.docs[index].id);

                    return GestureDetector(
                      onLongPress: isCurrentUser
                          ? () {
                              if (isSelected) {
                                _selectedMessageIds
                                    .remove(snapshot.data!.docs[index].id);
                              } else {
                                _selectedMessageIds
                                    .add(snapshot.data!.docs[index].id);
                              }
                              setState(() {});
                            }
                          : null,
                      onTap: isCurrentUser && isSelected
                          ? () {
                              _selectedMessageIds
                                  .remove(snapshot.data!.docs[index].id);
                              setState(() {});
                            }
                          : null,
                      child: Align(
                        alignment: isCurrentUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 5.0, horizontal: 10.0),
                          margin: EdgeInsets.symmetric(
                              vertical: 5.0, horizontal: 10.0),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.red[200]
                                : (isCurrentUser
                                    ? Colors.blue[200]
                                    : Colors.grey[300]),
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: Text(
                            messages[index]['text'],
                            style: TextStyle(
                                fontSize: fontSizeNotifier.fontSize,
                                color: isCurrentUser
                                    ? Colors.white
                                    : Colors.black),
                          ),
                        ),
                      ),
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
