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
  bool _isSearchBarVisible = false;

  Future<void> _searchByEmail() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      // Handle the case where the user is not signed in
      return;
    }

    final querySnapshot = await _firestore
        .collection('Susers')
        .where('email', isEqualTo: _emailController.text)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final foundUser = querySnapshot.docs.first.data();
      // Update the state to show the found user
      setState(() {
        _clients = [foundUser];
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No caretaker found with this email.')),
      );
    }
  }

  Future<void> _addClient() async {
  if (_clients.isNotEmpty) {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      // Handle the case where the user is not signed in
      return;
    }

    final caretakerUid = _clients[0]['uid'];

    // Check if the user is already in the caretaker's clientList
    final clientListSnapshot = await _firestore
        .collection('Clients')
        .doc(caretakerUid)
        .get();

    final clientList = (clientListSnapshot.data() as Map<String, dynamic>)['clientList'] ?? [];
    final isAlreadyAdded = clientList.any((client) => client['uid'] == currentUser.uid);

    if (isAlreadyAdded) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You are already added to this caretaker\'s client list.'),backgroundColor: Colors.red),
      );
    } else {
      // Add the currently signed-in user to the caretaker's clientList
      await _firestore.collection('Clients').doc(caretakerUid).set({
        'clientList': FieldValue.arrayUnion([
          {
            'uid': currentUser.uid,
            'displayName': currentUser.displayName,
            'email': currentUser.email,
          }
        ])
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User added successfully to caretaker\'s client list.'),backgroundColor: Colors.green),
      );
    }
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

  void _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LandingScreen()));
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
    title: Text('Find Caretaker'),
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
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () {
                      // Trigger the search operation when clicking the icon
                      _searchByEmail();
                    },
                  ),
                ],
              )
            : Align(
                alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isSearchBarVisible = true;
                    });
                  },
                  child: Text('Search'),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                        const Color.fromARGB(255, 30, 71, 104)),
                  ),
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
    ],
  ),
);

  }
}
