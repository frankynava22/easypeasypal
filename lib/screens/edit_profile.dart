import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  String? displayName;
  String? email;
  String? photoURL;
  String? selectedPhotoURL;
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadUserProfile();
  }

  void loadUserProfile() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      var userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (userDoc.exists) {
        setState(() {
          displayName = userDoc.data()?['displayName'];
          email = userDoc.data()?['email'];
          photoURL = userDoc.data()?['photoURL'];
          selectedPhotoURL = photoURL;
          _nameController.text = displayName ?? '';
        });
      }
    }
  }

  void saveProfile() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'displayName': _nameController.text,
        'photoURL': selectedPhotoURL ?? photoURL,
      });
      Navigator.pop(context);
    }
  }

  void showImageSelector() async {
    final profileImages = await FirebaseFirestore.instance
        .collection('profile_images')
        .doc('pics')
        .get();

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Color(0xFFF9F9F9),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: profileImages.data()!.entries.map((entry) {
                  String imageUrl = entry.value;
                  bool isSelected = selectedPhotoURL == imageUrl;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedPhotoURL = imageUrl;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: Color(0xFFA3EBB1), width: 2)
                            : null,
                      ),
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(imageUrl),
                        backgroundColor: Colors.grey[200],
                        radius: 40,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: TextStyle(color: Colors.white)),
        ),
        title: Text(
          'Edit Profile',
          style: TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: saveProfile,
            child: Text('Done', style: TextStyle(color: Colors.white)),
          ),
        ],
        backgroundColor: Color.fromARGB(255, 30, 71, 104),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          GestureDetector(
            onTap: showImageSelector,
            child: CircleAvatar(
              radius: 50,
              child: Icon(Icons.camera_alt,
                  color: Color.fromARGB(255, 30, 71, 104)),
              backgroundColor: Colors.grey[200],
            ),
          ),
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            color: Color(0xFFF9F9F9),
            child: TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          // ... other fields as needed ...
        ],
      ),
    );
  }
}
