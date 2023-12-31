import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'font_size_notifier.dart';
import 'font_weight_notifier.dart';
import 'edit_profile.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final double defaultFontSize = 18.0;
  bool isNotificationsEnabled = false;
  String? displayName;
  String? email;
  String? photoURL;

  @override
  void initState() {
    super.initState();
    loadSettings();
    loadNotificationSettings();
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
        });
      }
    }
  }

  void navigateToEditProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfilePage(
          onProfileUpdated: loadUserProfile,
        ),
      ),
    );
  }

  void loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final fontSizeNotifier =
        Provider.of<FontSizeNotifier>(context, listen: false);
    final fontWeightNotifier =
        Provider.of<FontWeightNotifier>(context, listen: false);

    double fontSize = prefs.getDouble('fontSize') ?? defaultFontSize;
    bool isBold = prefs.getBool('fontWeight') ?? false;

    fontSizeNotifier.fontSize = fontSize;
    fontWeightNotifier.fontWeight =
        isBold ? FontWeight.bold : FontWeight.normal;
  }

  void loadNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isNotificationsEnabled = prefs.getBool('notifications') ?? false;
    });
  }

  void saveFontSize(double fontSize) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setDouble('fontSize', fontSize);
  }

  void saveFontWeight(bool isBold) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('fontWeight', isBold);
  }

  void saveNotificationSettings(bool isEnabled) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('notifications', isEnabled);
    if (isEnabled) {
      enableNotifications();
    } else {
      disableNotifications();
    }
  }

  void enableNotifications() async {
    String? token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        FirebaseFirestore.instance.collection('users').doc(userId).set(
            {'fcmToken': token, 'unreadMessagesCount': FieldValue.increment(0)},
            SetOptions(merge: true));
      }
      FirebaseMessaging.instance.subscribeToTopic('chat_notifications');
    }
  }

  void disableNotifications() {
    FirebaseMessaging.instance.unsubscribeFromTopic('chat_notifications');
  }

  @override
  Widget build(BuildContext context) {
    final fontSizeNotifier = Provider.of<FontSizeNotifier>(context);
    final fontWeightNotifier = Provider.of<FontWeightNotifier>(context);

    TextStyle commonTextStyle = TextStyle(
      fontSize: fontSizeNotifier.fontSize,
      fontWeight: fontWeightNotifier.fontWeight,
    );

    TextStyle nameEmailStyle = TextStyle(
      fontSize: fontSizeNotifier.fontSize, // Use the dynamic font size
      fontWeight: fontWeightNotifier.fontWeight, // Use the dynamic font weight
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'SETTINGS',
          style: commonTextStyle.copyWith(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        backgroundColor: Color.fromARGB(255, 30, 71, 104),
        actions: [
          TextButton(
            onPressed: navigateToEditProfile,
            child: Text('Edit',
                style: commonTextStyle.copyWith(color: Colors.white)),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: ListView(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: photoURL?.isNotEmpty == true
                        ? NetworkImage(photoURL!)
                        : null,
                    child: photoURL == null || photoURL!.isEmpty
                        ? Icon(Icons.person, size: 50)
                        : null,
                  ),
                  SizedBox(height: 8),
                  Text(
                    displayName ?? '',
                    style: nameEmailStyle, // Apply dynamic style
                  ),
                  SizedBox(height: 4),
                  Text(
                    email ?? '',
                    style: nameEmailStyle, // Apply dynamic style
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 234, 242, 250),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: Text(
                        'Enable Notifications',
                        style: commonTextStyle,
                      ),
                      value: isNotificationsEnabled,
                      onChanged: (bool value) {
                        setState(() {
                          isNotificationsEnabled = value;
                          saveNotificationSettings(value);
                        });
                      },
                      activeColor: Color(0xFFA3EBB1),
                      inactiveThumbColor: Colors.grey,
                      inactiveTrackColor: Colors.grey[300],
                      activeTrackColor: Color(0xFFA3EBB1),
                    ),
                    const Divider(),
                    SwitchListTile(
                      title: Text(
                        'Bold Text',
                        style: commonTextStyle,
                      ),
                      value: fontWeightNotifier.fontWeight == FontWeight.bold,
                      onChanged: (bool isBold) {
                        setState(() {
                          fontWeightNotifier.fontWeight =
                              isBold ? FontWeight.bold : FontWeight.normal;
                          saveFontWeight(isBold);
                        });
                      },
                      activeColor: Color(0xFFA3EBB1),
                      inactiveThumbColor: Colors.grey,
                      inactiveTrackColor: Colors.grey[300],
                      activeTrackColor: Color(0xFFA3EBB1),
                    ),
                    const Divider(),
                    ListTile(
                      title: Text(
                        'Reset Font Size',
                        style: commonTextStyle,
                      ),
                      trailing: Icon(Icons.refresh,
                          color: Color.fromARGB(255, 30, 71, 104)),
                      onTap: () {
                        setState(() {
                          fontSizeNotifier.fontSize = defaultFontSize;
                          fontWeightNotifier.fontWeight = FontWeight.normal;
                          saveFontSize(defaultFontSize);
                          saveFontWeight(false);
                        });
                      },
                    ),
                    const Divider(),
                    ListTile(
                      title: Text(
                        'Font Size',
                        style: commonTextStyle,
                      ),
                      subtitle: Slider(
                        activeColor: Color.fromARGB(255, 30, 71, 104),
                        inactiveColor: Colors.grey[300],
                        min: 12.0,
                        max: 24.0,
                        divisions: 12,
                        value: fontSizeNotifier.fontSize,
                        onChanged: (newSize) {
                          setState(() {
                            fontSizeNotifier.fontSize = newSize;
                            saveFontSize(newSize);
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
