import 'package:flutter/material.dart';
import 'contacts.dart';
import 'messaging.dart';
import 'chat_history.dart';

class CommunicationScreen extends StatefulWidget {
  @override
  _CommunicationScreenState createState() => _CommunicationScreenState();
}

class _CommunicationScreenState extends State<CommunicationScreen> {
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
              icon: Icon(Icons.help_outline), // Question mark icon
              iconSize: 60.0,
              onPressed: () {
                // Trigger when the help button is pressed
                // For now, this does nothing, but you can later navigate to a help page
              },
            ),
          ],
        ),
      ),
    );
  }
}
