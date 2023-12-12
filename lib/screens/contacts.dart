import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_history.dart';
import 'package:provider/provider.dart';
import 'font_size_notifier.dart';

class ContactsScreen extends StatefulWidget {
  @override
  _ContactsScreenState createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  final _emailController = TextEditingController();
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  Map<String, dynamic>? _foundUser;
  List<Map<String, dynamic>> _contacts = [];
  bool _isSearchBarVisible = false;

  bool isUserAlreadyAdded(Map<String, dynamic>? user) {
    return _contacts.any((contact) => contact['email'] == user?['email']);
  }

  Future<void> _searchByEmail() async {
    final querySnapshot = await _firestore
        .collection('users')
        .where('email', isEqualTo: _emailController.text)
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      setState(() {
        _foundUser = querySnapshot.docs.first.data();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No user found with this email.')),
      );
    }
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

  Future<void> _deleteContact(Map<String, dynamic> contact) async {
    setState(() {
      _contacts.remove(contact);
    });

    await _firestore
        .collection('contacts')
        .doc(_auth.currentUser!.uid)
        .set({'contactsList': _contacts}, SetOptions(merge: true));
  }

  @override
  void initState() {
    super.initState();
    _fetchContacts();
  }

  @override
  Widget build(BuildContext context) {
    final fontSizeNotifier = Provider.of<FontSizeNotifier>(context);

    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Padding(
            padding: const EdgeInsets.only(right: 60.0), // Add left padding
            child: Text('Add Contacts',
                style: TextStyle(
                  fontSize: fontSizeNotifier.fontSize,
                  color: Color(0xFF1E4768), // Change text color
                )),
          ),
        ),
        backgroundColor: Colors.white, // Change background color to white
        iconTheme:
            IconThemeData(color: Color(0xFF1E4768)), // Change back button color
      ),
      body: Container(
        color: Color(0xFFF9F9F9), // Change background color of the screen
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _isSearchBarVisible
                  ? Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _emailController,
                            decoration:
                                InputDecoration(hintText: "Search by email..."),
                            style:
                                TextStyle(fontSize: fontSizeNotifier.fontSize),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.search),
                          onPressed: _searchByEmail,
                        ),
                      ],
                    )
                  : ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isSearchBarVisible = true;
                        });
                      },
                      child: Text('Search',
                          style: TextStyle(
                            fontSize: fontSizeNotifier.fontSize,
                            color: Colors.white, // Change text color
                          )),
                      style: ElevatedButton.styleFrom(
                        primary: Color(0xFF1E4768), // Change button color
                      ),
                    ),
            ),
            if (_foundUser != null)
              ListTile(
                title: Text(_foundUser!['displayName'] ?? '',
                    style: TextStyle(fontSize: fontSizeNotifier.fontSize)),
                subtitle: Text(_foundUser!['email'] ?? '',
                    style: TextStyle(fontSize: fontSizeNotifier.fontSize)),
                trailing: isUserAlreadyAdded(_foundUser)
                    ? Text("Added",
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: fontSizeNotifier.fontSize))
                    : ElevatedButton(
                        child: Text('Add',
                            style:
                                TextStyle(fontSize: fontSizeNotifier.fontSize)),
                        onPressed: () async {
                          // Add to local list
                          setState(() {
                            _contacts.add(_foundUser!);
                            _foundUser = null;
                          });

                          // Add to Firestore
                          await _firestore
                              .collection('contacts')
                              .doc(_auth.currentUser!.uid)
                              .set({'contactsList': _contacts},
                                  SetOptions(merge: true));
                        },
                      ),
              ),
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
                    color: Color.fromARGB(
                        255, 234, 242, 250), // Set background color
                    child: ListTile(
                      title: Text(_contacts[index]['displayName'] ?? '',
                          style:
                              TextStyle(fontSize: fontSizeNotifier.fontSize)),
                      subtitle: Text(_contacts[index]['email'] ?? '',
                          style:
                              TextStyle(fontSize: fontSizeNotifier.fontSize)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.chat),
                            color: Color(0xFF1E4768),
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => ChatHistoryScreen(
                                  contact: _contacts[index],
                                ),
                              ));
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            color: Color(0xFF1E4768),
                            onPressed: () {
                              _deleteContact(_contacts[index]);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
