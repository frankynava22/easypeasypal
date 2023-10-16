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
    // ... [same as before]
  }

  Future<void> _deleteSelectedMessages() async {
    // ... [same as before]
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.blueGrey[900],
        title: Text(widget.contact['displayName'] ?? 'Chat'),
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
                      // ... [same as before]
                      child: Align(
                        alignment: isCurrentUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          padding: EdgeInsets.all(10.0),
                          margin: EdgeInsets.symmetric(
                              vertical: 5.0, horizontal: 10.0),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.red[200]
                                : (isCurrentUser
                                    ? Colors.blue[300]
                                    : Colors.grey[300]),
                            borderRadius: BorderRadius.circular(20.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 1,
                                blurRadius: 2,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Text(
                            messages[index]['text'],
                            style: TextStyle(
                              color:
                                  isCurrentUser ? Colors.white : Colors.black,
                              fontSize: 16.0,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
            color: Colors.blueGrey[900],
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
                      hintText: "Enter your message...",
                      contentPadding: EdgeInsets.all(10.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                CircleAvatar(
                  backgroundColor: Colors.blue[300],
                  radius: 25,
                  child: IconButton(
                    icon: Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
