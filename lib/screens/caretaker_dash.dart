import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_history.dart';
import 'manage_client.dart';
import 'landing_screen.dart';
import 'communication.dart';

class CaretakerDashboardScreen extends StatefulWidget {
  @override
  _CaretakerDashboardScreenState createState() =>
      _CaretakerDashboardScreenState();
}

class _CaretakerDashboardScreenState extends State<CaretakerDashboardScreen> {
  final _emailController = TextEditingController();
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  Map<String, dynamic>? _foundUser;
  List<Map<String, dynamic>> _clients = [];
  bool _isSearchBarVisible = false;



// x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=>>
// x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=   F  U N C T I O N S   x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=>>
// x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=>>

  bool isUserAlreadyAdded(Map<String, dynamic>? user) {
    return _clients.any((client) => client['email'] == user?['email']);
  }

  Future<void> _fetchContacts() async {
    DocumentSnapshot snapshot = await _firestore
        .collection('Clients')
        .doc(_auth.currentUser!.uid)
        .get();
    if (snapshot.exists && snapshot.data() != null) {
      List contactsFromDb =
          (snapshot.data() as Map<String, dynamic>)['clientList'] ?? [];
      setState(() {
        _clients = List<Map<String, dynamic>>.from(contactsFromDb);
      });
    }
  }

  Future<void> _deleteContact(Map<String, dynamic> client) async {
    // Remove from local list
    setState(() {
      _clients.remove(client);
    });

    // Remove from Firestore - Clients collection
    await _firestore.collection('Clients').doc(_auth.currentUser!.uid).set(
      {
        'clientList': _clients.map((client) {
          return {
            'uid': client['uid'], // Add the UID here
            'displayName': client['displayName'],
            'email': client['email'],
          };
        }).toList()
      },
      SetOptions(merge: true),
    );

    // Remove from Firestore - CaretakerList collection
    await _firestore.collection('CaretakerList').doc(client['uid']).update({
      'caretakers': FieldValue.arrayRemove([
        {
          'uid': _auth.currentUser!.uid,
          'displayName': _auth.currentUser!.displayName,
          'email': _auth.currentUser!.email,
        }
      ]),
    });

    // Remove from Firestore - Contacts collection (Caretaker's side)
    await _firestore.collection('contacts').doc(_auth.currentUser!.uid).update({
      'contactsList': FieldValue.arrayRemove([
        {
          'uid': client['uid'],
          'displayName': client['displayName'],
          'email': client['email'],
        }
      ]),
    });

    // Remove from Firestore - Contacts collection (Client's side)
    await _firestore.collection('contacts').doc(client['uid']).update({
      'contactsList': FieldValue.arrayRemove([
        {
          'uid': _auth.currentUser!.uid,
          'displayName': _auth.currentUser!.displayName,
          'email': _auth.currentUser!.email,
        }
      ]),
    });
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


// x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=>>
// x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=     W I D G E T S      x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=>>
// x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=>>


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Clients'),
        backgroundColor: const Color.fromARGB(255, 30, 71, 104),
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
                            return {
                              'uid': client['uid'],
                              'displayName': client['displayName'],
                              'email': client['email'],
                            };
                          }).toList()
                        }, SetOptions(merge: true));
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
                              builder: (context) =>
                                  ManageClientScreen(clientUid: clientUid),
                            ),
                          );
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
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CommunicationScreen(),
                ),
              );
            },
            child: Text('Communication'),
          ),
        ],
      ),
    );
  }
}
