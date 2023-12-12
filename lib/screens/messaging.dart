import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'chat_history.dart';
import 'contacts.dart';
import 'font_size_notifier.dart';

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

  bool _buttonClicked = false;

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
        title: Center(
          child: Padding(
            padding: const EdgeInsets.only(right: 60.0), // Add left padding
            child: Text('Chat History',
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
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 20.0),
            Expanded(
              child: ListView.builder(
                itemCount: _contacts.length,
                itemBuilder: (context, index) {
                  return Card(
                    // Wrap ListTile in Card
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12.0), // Add border radius
                    ),
                    margin: EdgeInsets.all(8.0), // Add margin
                    color: Color(0xFFEAF2FA), // Set background color
                    child: ListTile(
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
                        color: Color(0xFF1E4768), // Change chat icon color
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) =>
                                ChatHistoryScreen(contact: _contacts[index]),
                          ));
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _buttonClicked
                ? Colors.white // Background color when clicked
                : const Color.fromARGB(
                    255, 30, 71, 104), // Default background color
          ),
          child: InkWell(
            onTap: () {
              setState(() {
                _buttonClicked = !_buttonClicked;
              });
              Future.delayed(Duration(milliseconds: 300), () {
                Navigator.of(context).push(_createRoute());
                // Reset the button to default colors after the page transition
                Future.delayed(Duration(milliseconds: 300), () {
                  setState(() {
                    _buttonClicked = false;
                  });
                });
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Icon(
                Icons.add,
                size: 32.0,
                color: _buttonClicked
                    ? const Color.fromARGB(
                        255, 30, 71, 104) // Icon color when clicked
                    : Colors.white, // Default icon color
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  // Function to create a custom route with Hero animation
  Route _createRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => ContactsScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;
        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(position: offsetAnimation, child: child);
      },
    );
  }
}
