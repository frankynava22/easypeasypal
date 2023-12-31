import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotesScreen extends StatefulWidget {
  @override
  _NotesScreenState createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final TextEditingController _titleController = TextEditingController(); // text edit controllers
  final TextEditingController _noteController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;  // firestore db isntance
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _addNote() async { // function to add new note to firestore
    final String title = _titleController.text.trim();
    final String note = _noteController.text.trim();
    final String userId = _auth.currentUser!.uid;

    if (title.isNotEmpty && note.isNotEmpty) {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('personal_websites')
          .add({'name': title, 'url': note});

      _titleController.clear();
      _noteController.clear();
    }
  }

  Future<void> _deleteNote(String docId) async { // delete notes function
    final String userId = _auth.currentUser!.uid;

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('personal_websites')
        .doc(docId)
        .delete();
  }

  Stream<QuerySnapshot> _notesStream() { // notes loader from db
    final String userId = _auth.currentUser!.uid;
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('personal_websites')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Personal Notes',style: TextStyle(color: const Color.fromARGB(255, 30, 71, 104), fontSize: 18),),
        centerTitle: true,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: const Color.fromARGB(255, 30, 71, 104)), 
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Note Title',border: OutlineInputBorder(),),
            ),
            SizedBox(height: 8.0),
            TextField(
              controller: _noteController,
              maxLines: null,
              decoration: InputDecoration(labelText: 'Note Text',border: OutlineInputBorder(),),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _addNote,
              child: Text('Add Note'),
              style: ElevatedButton.styleFrom(primary: const Color.fromARGB(255, 30, 71, 104),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0),),),
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _notesStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No notes added yet.'));
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var document = snapshot.data!.docs[index];
                      return Card(
                        color: Color.fromARGB(255, 234, 242, 250),
                        child: ListTile(
                          title: Text(document['name']),
                          subtitle: Text(document['url']),
                          trailing: IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              _deleteNote(document.id);
                            },
                          ),
                        ),
                      );
                    },
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
