import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'contacts.dart';
import 'messaging.dart';
import 'chat_history.dart';
import 'font_size_notifier.dart'; // Import FontSizeNotifier
import 'font_weight_notifier.dart'; // Import FontWeightNotifier

// CommunicationScreen is a StatefulWidget to manage communication options
class CommunicationScreen extends StatefulWidget {
  @override
  _CommunicationScreenState createState() => _CommunicationScreenState();
}

// State class for CommunicationScreen
class _CommunicationScreenState extends State<CommunicationScreen> {
  void _showHelpModal() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        // Providers for dynamic font size and weight
        final fontSizeNotifier = Provider.of<FontSizeNotifier>(context);
        final fontWeightNotifier = Provider.of<FontWeightNotifier>(
            context); // Get the current font weight

        // Padding widget containing columns of help tiles
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Help tile for 'Chat' feature
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
      },
    );
  }

  // Function to create a ListTile as a help tile
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

  // Building the UI for CommunicationScreen
  @override
  Widget build(BuildContext context) {
    // Providers for dynamic font size and weight
    final fontSizeNotifier = Provider.of<FontSizeNotifier>(context);
    final fontWeightNotifier =
        Provider.of<FontWeightNotifier>(context); // Get the current font weight

    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Padding(
            padding: const EdgeInsets.only(right: 60.0), // Add left padding
            child: Text('Chat Menu',
                style: TextStyle(
                  fontSize: fontSizeNotifier.fontSize,
                  color: Color(0xFF1E4768), // Change text color
                )),
          ),
        ),
        backgroundColor: Colors.white, // Change background color to ARGB
        iconTheme:
            IconThemeData(color: Color(0xFF1E4768)), // Change back button color
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Menu option for 'Chat'
            _menuOption("Chat", Icons.chat, () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => MessagingScreen()),
              );
            }, fontSizeNotifier.fontSize,
                fontWeightNotifier.fontWeight), // Apply font weight
            // Menu option for 'Contacts'
            _menuOption("Contacts", Icons.contacts, () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => ContactsScreen()),
              );
            }, fontSizeNotifier.fontSize,
                fontWeightNotifier.fontWeight), // Apply font weight
            // Menu option for 'Help'
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

  // Function to create a menu option widget
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
                  fontWeight: fontWeight,
                  color: const Color.fromARGB(255, 30, 71, 104))),
          SizedBox(height: 10.0),
          InkWell(
            onTap: onTap,
            child: Icon(icon,
                size: 50.0, color: const Color.fromARGB(255, 30, 71, 104)),
          ),
        ],
      ),
    );
  }
}
