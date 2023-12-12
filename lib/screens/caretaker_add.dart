import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'landing_screen.dart';

class CaretakerAddScreen extends StatefulWidget {
  @override
  _CaretakerAddScreenState createState() => _CaretakerAddScreenState();
}

class _CaretakerAddScreenState extends State<CaretakerAddScreen> {
  final _emailController = TextEditingController();
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> _clients = [];
  List<Map<String, dynamic>> _caretakersList = [];
  bool _isSearchBarVisible = false;


// x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=>>
// x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=   F  U N C T I O N S   x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=>>
// x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=>>
  void _clearClientsList() {
  setState(() {
    _clients = [];
  });
}
  
  
  Future<void> _searchByEmail() async {
  final currentUser = _auth.currentUser;
  if (currentUser == null) {
    // Handle the case where the user is not signed in
    return;
  }

  if (_emailController.text.isEmpty) {
    // Clear the _clients list when no search is performed
    setState(() {
      _clients = [];
    });
    return;
  }

  final querySnapshot = await _firestore
      .collection('Susers')
      .where('email', isEqualTo: _emailController.text)
      .get();

  setState(() {
    _clients = querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  });

  if (_clients.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('No caretaker found with this email.')),
    );
  }
}




  Future<void> _addClient() async {
  if (_clients.isNotEmpty && _clients[0] != null) {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      // Handle the case where the user is not signed in
      return;
    }

    final caretakerUid = _clients[0]['uid'];

    // Check if the user is already in the caretaker's clientList
    final clientListSnapshot =
        await _firestore.collection('Clients').doc(caretakerUid).get();

    final clientList =
        (clientListSnapshot.data() as Map<String, dynamic>?)?['clientList'] ??
            [];
    final isAlreadyAdded =
        clientList.any((client) => client['uid'] == currentUser.uid);

    if (isAlreadyAdded) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You are already added to this caretaker\'s client list.'),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      // Add the currently signed-in user to the caretaker's clientList
      await _firestore.collection('Clients').doc(caretakerUid).set(
        {
          'clientList': FieldValue.arrayUnion([
            {
              'uid': currentUser.uid,
              'displayName': currentUser.displayName,
              'email': currentUser.email,
            }
          ])
        },
        SetOptions(merge: true),
      );

      // Add the caretaker to the user's CaretakerList
      await _firestore.collection('CaretakerList').doc(currentUser.uid).set(
        {
          'caretakers': FieldValue.arrayUnion([
            {
              'uid': caretakerUid,
              'displayName': _clients[0]!['displayName'],
              'email': _clients[0]!['email'],
            }
          ])
        },
        SetOptions(merge: true),
      );

      // Add the client user to the caretaker's contacts
      await _firestore.collection('contacts').doc(caretakerUid).set(
        {
          'contactsList': FieldValue.arrayUnion([
            {
              'uid': currentUser.uid,
              'displayName': currentUser.displayName,
              'email': currentUser.email,
            }
          ])
        },
        SetOptions(merge: true),
      );

      await _firestore.collection('contacts').doc(currentUser.uid).set(
        {
          'contactsList': FieldValue.arrayUnion([
            {
              'uid': caretakerUid,
              'displayName': _clients[0]!['displayName'],
              'email': _clients[0]!['email'],
            }
          ])
        },
        SetOptions(merge: true),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('User added successfully to caretaker\'s client list.'),
          backgroundColor: Colors.green,
        ),
      );
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('No caretaker found with this email.'),
        backgroundColor: Colors.red,
      ),
    );
  }
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

  Future<void> _fetchCaretakers() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      // Handle the case where the user is not signed in
      return;
    }

    final caretakerListSnapshot =
        await _firestore.collection('CaretakerList').doc(currentUser.uid).get();

    if (caretakerListSnapshot.exists) {
      final caretakersFromDb = (caretakerListSnapshot.data()
              as Map<String, dynamic>)['caretakers'] ??
          [];
      setState(() {
        _caretakersList = List<Map<String, dynamic>>.from(caretakersFromDb);
      });
    }
  }

  void _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LandingScreen()));
  }

  @override
  void initState() {
    super.initState();
    
    _fetchCaretakers(); // Call the method to load caretakers
    _clearClientsList();
  }


// x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=>>
// x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=     W I D G E T S      x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=>>
// x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=>>
   @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Find Caretaker'),
        backgroundColor: const Color.fromARGB(255, 30, 71, 104),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _signOut(context),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  _isSearchBarVisible
                      ? Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _emailController,
                                decoration: InputDecoration(
                                  hintText: "Search by email...",
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.search),
                              onPressed: () {
                                _searchByEmail();
                              },
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
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                              const Color.fromARGB(255, 30, 71, 104),
                            ),
                          ),
                        ),
                  if (_clients.isNotEmpty)
                    ListTile(
                      title: Text(_clients[0]['displayName'] ?? ''),
                      subtitle: Text(_clients[0]['email'] ?? ''),
                      trailing: ElevatedButton(
                        child: Text('Add'),
                        onPressed: _addClient,
                      ),
                    ),
                  if (_caretakersList.isNotEmpty)
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8.0,
                            horizontal: 16.0,
                          ),
                          child: Text(
                            'Current Caretakers',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        ..._caretakersList.map(
                          (caretaker) => ListTile(
                            title: Text(caretaker['displayName'] ?? ''),
                            subtitle: Text(caretaker['email'] ?? ''),
                          ),
                        ),
                      ],
                    ),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

