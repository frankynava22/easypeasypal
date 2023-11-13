import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_history.dart'; // Import the ChatHistoryScreen
import 'manage_client.dart';
import 'landing_screen.dart';

class CaretakerDashboardScreen extends StatefulWidget {
  @override
  _CaretakerDashboardScreenState createState() => _CaretakerDashboardScreenState();
}

class _CaretakerDashboardScreenState extends State<CaretakerDashboardScreen> {
  final _emailController = TextEditingController();
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  Map<String, dynamic>? _foundUser;
  List<Map<String, dynamic>> _clients = [];
  bool _isSearchBarVisible = false;

  bool isUserAlreadyAdded(Map<String, dynamic>? user) {
    return _clients.any((client) => client['email'] == user?['email']);
  }

  //Future<void> _searchByEmail() async {
  //  final querySnapshot = await _firestore
  //      .collection('users')
  //      .where('email', isEqualTo: _emailController.text)
  //      .get();
  //  if (querySnapshot.docs.isNotEmpty) {
  //    setState(() {
  //      _foundUser = querySnapshot.docs.first.data();
  //    });
  //  } else {
  //    ScaffoldMessenger.of(context).showSnackBar(
  //      SnackBar(content: Text('No user found with this email.')),
  //    );
  //  }
  //}

  Future<void> _fetchContacts() async {
    DocumentSnapshot snapshot = await _firestore
        .collection('Clients')
        .doc(_auth.currentUser!.uid)
        .get();
    if (snapshot.exists && snapshot.data() != null) {
      List contactsFromDb = (snapshot.data() as Map<String, dynamic>)['clientList'] ?? [];
      setState(() {
        _clients = List<Map<String, dynamic>>.from(contactsFromDb);
      });
    }
  }

  Future<void> _deleteContact(Map<String, dynamic> client) async {
    setState(() {
      _clients.remove(client);
    });

    await _firestore
        .collection('Clients')
        .doc(_auth.currentUser!.uid)
        .set({
          'clientList': _clients.map((client) {
            // Include UID and other client data
            return {
              'uid': client['uid'],  // Add the UID here
              'displayName': client['displayName'],
              'email': client['email'],
              // Add more fields as needed
            };
          }).toList()
        },
        SetOptions(merge: true));
  }

  @override
  void initState() {
    super.initState();
    _fetchContacts();
  }

  void _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LandingScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Clients'),backgroundColor: const Color.fromARGB(255, 30, 71, 104),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _signOut(context),
          )
        ],
      ),
      body: Column(
        children: [
          
          if (_foundUser != null)
            ListTile(
              title: Text(_foundUser!['displayName'] ?? ''),
              subtitle: Text(_foundUser!['email'] ?? ''),
              trailing: isUserAlreadyAdded(_foundUser)
                  ? Text("Added", style: TextStyle(color: Colors.grey))
                  : ElevatedButton(
                      child: Text('Add'),
                      onPressed: () async {
                        // Add to local list
                        setState(() {
                          _clients.add(_foundUser!);
                          _foundUser = null;
                        });

                        // Add to Firestore
                        await _firestore
                            .collection('Clients')
                            .doc(_auth.currentUser!.uid)
                            .set({
                              'clientList': _clients.map((client) {
                                // Include UID and other client data
                                return {
                                  'uid': client['uid'],  // Add the UID here
                                  'displayName': client['displayName'],
                                  'email': client['email'],
                                  // Add more fields as needed
                                };
                              }).toList()
                            },
                            SetOptions(merge: true));
                      },
                    ),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: _clients.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_clients[index]['displayName'] ?? ''),
                  subtitle: Text(_clients[index]['email'] ?? ''),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.manage_accounts),
                        onPressed: () {
                          // Access the UID using _clients[index]['uid']
                          String clientUid = _clients[index]['uid'];
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ManageClientScreen(clientUid: clientUid),
                              ),
                            );
                                                      // Use clientUid as needed
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          _deleteContact(_clients[index]);
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
    );
  }
}
