import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_history.dart'; // Add this import for the ChatHistoryScreen
import 'contacts.dart'; // Import the contacts.dart file

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
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedHeader.isEmpty ? 'Messaging' : _selectedHeader),
        leading: !_isOnMainScreen
            ? IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  _toggleScreen('');
                },
              )
            : null,
      ),
      body: Center(
        child: _isOnMainScreen
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      _toggleScreen('Chats');
                      _fetchContacts(); // Fetch contacts when "Chats" is tapped
                    },
                    icon: Icon(Icons.chat),
                    label: Text('Chats'),
                  ),
                ],
              )
            : _selectedHeader == 'Chats'
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(height: 20.0),
                      Text(
                        _selectedHeader,
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _contacts.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title:
                                  Text(_contacts[index]['displayName'] ?? ''),
                              subtitle: Text(_contacts[index]['email'] ?? ''),
                              trailing: IconButton(
                                icon: Icon(Icons.chat),
                                onPressed: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => ChatHistoryScreen(
                                        contact: _contacts[index]),
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
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      // ... [Your other code if any, for other headers]
                    ],
                  ),
      ),
    );
  }
}
