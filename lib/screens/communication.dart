import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'contacts.dart';
import 'messaging.dart';
import 'chat_history.dart';
import 'font_size_notifier.dart'; // Import FontSizeNotifier
import 'font_weight_notifier.dart'; // Import FontWeightNotifier

class CommunicationScreen extends StatefulWidget {
  @override
  _CommunicationScreenState createState() => _CommunicationScreenState();
}

class _CommunicationScreenState extends State<CommunicationScreen> {
  void _showHelpModal() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          final fontSizeNotifier = Provider.of<FontSizeNotifier>(context);
          final fontWeightNotifier = Provider.of<FontWeightNotifier>(
              context); // Get the current font weight

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _helpTile(
                    icon: Icons.chat,
                    title: "Chat",
                    subtitle:
                        "Click this to enter the chat room and start messaging.",
                    fontSize: fontSizeNotifier.fontSize,
                    fontWeight:
                        fontWeightNotifier.fontWeight), // Apply font weight
                SizedBox(height: 20),
                _helpTile(
                    icon: Icons.contacts,
                    title: "Contacts",
                    subtitle: "Click this to view and manage your contacts.",
                    fontSize: fontSizeNotifier.fontSize,
                    fontWeight:
                        fontWeightNotifier.fontWeight), // Apply font weight
              ],
            ),
          );
        });
  }

  ListTile _helpTile(
      {required IconData icon,
      required String title,
      String? subtitle,
      required double fontSize,
      required FontWeight fontWeight}) {
    // Add fontWeight parameter
    return ListTile(
      leading: Icon(icon, size: 35.0, color: Colors.blueGrey[800]),
      title: Text(title,
          style: TextStyle(
              fontWeight: fontWeight, fontSize: fontSize)), // Apply font weight
      subtitle: Text(subtitle ?? '',
          style: TextStyle(
              fontSize: fontSize, fontWeight: fontWeight)), // Apply font weight
    );
  }

  @override
  Widget build(BuildContext context) {
    final fontSizeNotifier = Provider.of<FontSizeNotifier>(context);
    final fontWeightNotifier =
        Provider.of<FontWeightNotifier>(context); // Get the current font weight

    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.blueGrey[900],
        title: Text('Chat Room',
            style: TextStyle(
                fontSize: fontSizeNotifier.fontSize,
                fontWeight:
                    fontWeightNotifier.fontWeight)), // Apply font weight
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _menuOption("Chat", Icons.chat, () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => MessagingScreen()),
              );
            }, fontSizeNotifier.fontSize,
                fontWeightNotifier.fontWeight), // Apply font weight
            _menuOption("Contacts", Icons.contacts, () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => ContactsScreen()),
              );
            }, fontSizeNotifier.fontSize,
                fontWeightNotifier.fontWeight), // Apply font weight
            _menuOption(
                "Help",
                Icons.help_outline,
                _showHelpModal,
                fontSizeNotifier.fontSize,
                fontWeightNotifier.fontWeight), // Apply font weight
          ],
        ),
      ),
    );
  }

  Widget _menuOption(String title, IconData icon, VoidCallback onTap,
      double fontSize, FontWeight fontWeight) {
    // Add fontWeight parameter
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15.0),
      child: Column(
        children: [
          Text(title,
              style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: fontWeight, // Apply font weight
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
