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
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _helpTile(
                    icon: Icons.chat,
                    title: "Chat",
                    subtitle:
                        "Click this to enter the chat room and start messaging."),
                SizedBox(height: 20),
                _helpTile(
                    icon: Icons.contacts,
                    title: "Contacts",
                    subtitle: "Click this to view and manage your contacts."),
              ],
            ),
          );
        });
  }

  ListTile _helpTile(
      {required IconData icon, required String title, String? subtitle}) {
    return ListTile(
      leading: Icon(icon, size: 35.0, color: Colors.blueGrey[800]),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle ?? ''),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.blueGrey[900],
        title: Text('Chat Room'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _menuOption("Chat", Icons.chat, () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => MessagingScreen()),
              );
            }),
            _menuOption("Contacts", Icons.contacts, () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => ContactsScreen()),
              );
            }),
            _menuOption("Help", Icons.help_outline, _showHelpModal),
          ],
        ),
      ),
    );
  }

  Widget _menuOption(String title, IconData icon, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15.0),
      child: Column(
        children: [
          Text(title,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.blueGrey[800])),
          SizedBox(height: 10.0),
          InkWell(
            onTap: onTap,
            child: Icon(icon, size: 50.0, color: Colors.blueGrey[500]),
          ),
        ],
      ),
    );
  }
}
