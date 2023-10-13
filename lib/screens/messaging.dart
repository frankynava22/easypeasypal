import 'package:flutter/material.dart';

class MessagingScreen extends StatefulWidget {
  @override
  _MessagingScreenState createState() => _MessagingScreenState();
}

class _MessagingScreenState extends State<MessagingScreen> {
  final List<String> messages = []; // this will store the chat messages
  final TextEditingController _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Room'),
        actions: [
          IconButton(
            icon: Icon(Icons.chat),
            onPressed: () {
              // Trigger when the new chat button is pressed
            },
          ),
          IconButton(
            icon: Icon(Icons.contacts),
            onPressed: () {
              // Trigger when the contact list button is pressed
            },
          ),
          IconButton(
            icon: Icon(Icons.help_outline), // Question mark icon
            onPressed: () {
              // Trigger when the help button is pressed
              // For now, this does nothing, but you can later navigate to a help page
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(messages[index]),
                  // Additional customization like determining the sender and showing the message on the left or right can be done
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
                    decoration:
                        InputDecoration(hintText: "Enter your message..."),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    if (_messageController.text.isNotEmpty) {
                      setState(() {
                        messages.add(_messageController.text);
                      });
                      _messageController.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
