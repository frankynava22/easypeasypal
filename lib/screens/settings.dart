import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_notifier.dart'; // Don't forget to create theme_notifier.dart as described in the previous response

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text("Dark Theme"),
            value: _darkMode,
            onChanged: (bool value) {
              setState(() {
                _darkMode = value;
              });
              if (_darkMode) {
                Provider.of<ThemeNotifier>(context, listen: false)
                    .setTheme(ThemeData.dark());
              } else {
                Provider.of<ThemeNotifier>(context, listen: false)
                    .setTheme(ThemeData.light());
              }
            },
          ),
          // You can add more settings options below
        ],
      ),
    );
  }
}
