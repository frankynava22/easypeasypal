import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'font_size_notifier.dart';
import 'font_weight_notifier.dart';

class EditProfilePage extends StatefulWidget {
  final VoidCallback onProfileUpdated;

  EditProfilePage({required this.onProfileUpdated});

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
      widget.onProfileUpdated(); // Call the callback function
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
                      Navigator.of(context).pop(); // Close the modal sheet
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
    final fontSizeNotifier = Provider.of<FontSizeNotifier>(context);
    final fontWeightNotifier = Provider.of<FontWeightNotifier>(context);

    TextStyle dynamicTextStyle = TextStyle(
      fontSize: fontSizeNotifier.fontSize,
      fontWeight: fontWeightNotifier.fontWeight,
    );

    return Scaffold(
      appBar: AppBar(
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Back', style: TextStyle(color: Colors.white)),
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Color(0xFFF9F9F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                controller: _nameController,
                style: TextStyle(
                  fontSize: Provider.of<FontSizeNotifier>(context).fontSize,
                  fontWeight:
                      Provider.of<FontWeightNotifier>(context).fontWeight,
                ),
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
