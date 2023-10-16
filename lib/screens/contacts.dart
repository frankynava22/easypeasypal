import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_history.dart'; // Import the ChatHistoryScreen

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
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.blueGrey[900] ?? Colors.blueGrey,
        title: Text('Contacts', style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _isSearchBarVisible
                ? Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            hintText: "Search by email...",
                            hintStyle: TextStyle(
                                color: Colors.blueGrey[500] ?? Colors.blueGrey),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.blueGrey[700] ?? Colors.blueGrey,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.blueGrey[700] ?? Colors.blueGrey,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.blueGrey[900] ?? Colors.blueGrey,
                              ),
                            ),
                          ),
                          style: TextStyle(
                              color: Colors.blueGrey[800] ?? Colors.blueGrey),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.search,
                            color: Colors.blueGrey[500] ?? Colors.blueGrey),
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
                    child: Text('Search'),
                    style: ElevatedButton.styleFrom(
                        primary: Colors.blueGrey[800] ?? Colors.blueGrey),
                  ),
          ),
          if (_foundUser != null)
            ListTile(
              title: Text(_foundUser!['displayName'] ?? '',
                  style: TextStyle(
                      color: Colors.blueGrey[700] ?? Colors.blueGrey)),
              subtitle: Text(_foundUser!['email'] ?? '',
                  style: TextStyle(
                      color: Colors.blueGrey[500] ?? Colors.blueGrey)),
              trailing: isUserAlreadyAdded(_foundUser)
                  ? Text("Added", style: TextStyle(color: Colors.grey))
                  : ElevatedButton(
                      child: Text('Add', style: TextStyle(color: Colors.white)),
                      onPressed: () async {
                        setState(() {
                          _contacts.add(_foundUser!);
                          _foundUser = null;
                        });

                        await _firestore
                            .collection('contacts')
                            .doc(_auth.currentUser!.uid)
                            .set({'contactsList': _contacts},
                                SetOptions(merge: true));
                      },
                      style: ElevatedButton.styleFrom(
                          primary: Colors.blueGrey[800] ?? Colors.blueGrey),
                    ),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: _contacts.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_contacts[index]['displayName'] ?? '',
                      style: TextStyle(
                          color: Colors.blueGrey[700] ?? Colors.blueGrey)),
                  subtitle: Text(_contacts[index]['email'] ?? '',
                      style: TextStyle(
                          color: Colors.blueGrey[500] ?? Colors.blueGrey)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.chat,
                            color: Colors.blueGrey[500] ?? Colors.blueGrey),
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) =>
                                ChatHistoryScreen(contact: _contacts[index]),
                          ));
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red[400]),
                        onPressed: () {
                          _deleteContact(_contacts[index]);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      backgroundColor: Colors.blueGrey[100] ?? Colors.blueGrey,
    );
  }
}
