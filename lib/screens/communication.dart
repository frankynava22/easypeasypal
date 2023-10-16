import 'package:flutter/material.dart';
import 'contacts.dart';
import 'messaging.dart';
import 'chat_history.dart';

class CommunicationScreen extends StatefulWidget {
  @override
  _CommunicationScreenState createState() => _CommunicationScreenState();
}

class _CommunicationScreenState extends State<CommunicationScreen> {
  void _showHelpModal() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(Icons.chat, size: 40.0),
                  title: Text("Chat"),
                  subtitle: Text(
                      "Click this to enter the chat room and start messaging."),
                ),
                SizedBox(height: 10),
                ListTile(
                  leading: Icon(Icons.contacts, size: 40.0),
                  title: Text("Contacts"),
                  subtitle:
                      Text("Click this to view and manage your contacts."),
                ),
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Room'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Chat",
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
            IconButton(
              icon: Icon(Icons.chat),
              iconSize: 60.0,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => MessagingScreen()),
                );
              },
            ),
            SizedBox(height: 20.0),
            Text("Contacts",
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
            IconButton(
              icon: Icon(Icons.contacts),
              iconSize: 60.0,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => ContactsScreen()),
                );
              },
            ),
            SizedBox(height: 20.0),
            Text("Help",
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
            IconButton(
              icon: Icon(Icons.help_outline),
              iconSize: 60.0,
              onPressed: _showHelpModal,
            ),
          ],
        ),
      ),
    );
  }
}
