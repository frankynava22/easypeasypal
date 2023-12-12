import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'chat_history.dart'; // Add this import for the ChatHistoryScreen
import 'contacts.dart'; // Import the contacts.dart file
import 'font_size_notifier.dart'; // Import FontSizeNotifier

class MessagingScreen extends StatefulWidget {
  @override
  _MessagingScreenState createState() => _MessagingScreenState();
}

class _MessagingScreenState extends State<MessagingScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final TextEditingController _messageController = TextEditingController();

  List<Map<String, dynamic>> _contacts = [];
  List<String> messages = [];

  bool _isOnMainScreen = true;
  String _selectedHeader = '';

  void _toggleScreen(String header) {
    setState(() {
      _isOnMainScreen = !_isOnMainScreen;
      _selectedHeader = header;
    });
  }

  Future<void> _fetchContacts() async {
    DocumentSnapshot snapshot = await _firestore
        .collection('contacts')
        .doc(_auth.currentUser!.uid)
        .get();
    if (snapshot.exists && snapshot.data() != null) {
      List contactsFromDb =
          (snapshot.data() as Map<String, dynamic>)['contactsList'] ?? [];
      setState(() {
        _contacts = List<Map<String, dynamic>>.from(contactsFromDb);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final fontSizeNotifier = Provider.of<FontSizeNotifier>(context);

    // Fetch contacts when the screen is built
    _fetchContacts();

    return Scaffold(
      appBar: AppBar(
        title: Text('Chats', style: TextStyle(fontSize: fontSizeNotifier.fontSize)),
        backgroundColor: const Color.fromARGB(255, 30, 71, 104),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 20.0),
            Text(
              'Chats',
              style: TextStyle(
                fontSize: fontSizeNotifier.fontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _contacts.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      _contacts[index]['displayName'] ?? '',
                      style: TextStyle(fontSize: fontSizeNotifier.fontSize),
                    ),
                    subtitle: Text(
                      _contacts[index]['email'] ?? '',
                      style: TextStyle(fontSize: fontSizeNotifier.fontSize),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.chat),
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => ChatHistoryScreen(contact: _contacts[index]),
                        ));
                      },
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ContactsScreen(),
                    ),
                  );
                },
                child: Text(
                  "Don't see who you're looking for? Add them to your contacts!",
                  style: TextStyle(
                    fontSize: fontSizeNotifier.fontSize,
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
