import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

class WebsitesScreen extends StatefulWidget {
  @override
  _WebsitesScreenState createState() => _WebsitesScreenState();
}

class _WebsitesScreenState extends State<WebsitesScreen> {
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _addWebsite() async {
    final String url = _urlController.text.trim();
    final String name = _nameController.text.trim();
    final String userId = _auth.currentUser!.uid;

    if (url.isNotEmpty && name.isNotEmpty) {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('personal_websites')
          .add({'url': url, 'name': name});

      _urlController.clear();
      _nameController.clear();
    }
  }

  Stream<QuerySnapshot> _websitesStream() {
    final String userId = _auth.currentUser!.uid;
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('personal_websites')
        .snapshots();
  }

  Future<void> _launchURL(String url) async {
    print('Attempting to launch URL: $url'); // Debugging statement

    try {
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        print('Cannot launch URL: $url'); // Debugging statement
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch $url')),
        );
      }
    } catch (e) {
      print('Error launching URL: $e'); // Debugging statement
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error launching URL')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Personal Websites'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _urlController,
              decoration: InputDecoration(
                labelText: 'Website URL',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 8.0),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Website Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _addWebsite,
              child: Text('Add Website'),
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _websitesStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No websites added yet.'));
                  }

                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, // Number of columns
                      crossAxisSpacing: 10, // Horizontal spacing
                      mainAxisSpacing: 10, // Vertical spacing
                    ),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var document = snapshot.data!.docs[index];
                      return InkWell(
                        onTap: () => _launchURL(document['url']),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Icon(Icons.web, size: 50), // Random icon for now
                            Text(document['name'],
                                overflow: TextOverflow.ellipsis),
                          ],
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
