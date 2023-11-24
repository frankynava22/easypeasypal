import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'theme_notifier.dart';
import 'font_size_notifier.dart';
import 'font_weight_notifier.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final double defaultFontSize = 18.0;
  bool isNotificationsEnabled = false;

  @override
  void initState() {
    super.initState();
    loadSettings();
    loadNotificationSettings();
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
        FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({'fcmToken': token});
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

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: commonTextStyle,
        ),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: Text(
              'Theme',
              style: commonTextStyle,
            ),
            trailing: Icon(Icons.palette),
            onTap: () {
              // Implement theme change logic
            },
          ),
          ListTile(
            title: Text(
              'Font Size',
              style: commonTextStyle,
            ),
            subtitle: Slider(
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
          ),
          ListTile(
            title: Text(
              'Reset Font Size',
              style: commonTextStyle,
            ),
            trailing: Icon(Icons.restore),
            onTap: () {
              setState(() {
                fontSizeNotifier.fontSize = defaultFontSize;
                fontWeightNotifier.fontWeight = FontWeight.normal;
                saveFontSize(defaultFontSize);
                saveFontWeight(false);
              });
            },
          ),
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
          ),
          // Add other settings options here
        ],
      ),
    );
  }
}
