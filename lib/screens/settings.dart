import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_notifier.dart';
import 'font_size_notifier.dart';
import 'font_weight_notifier.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final double defaultFontSize = 18.0;

  void saveFontSize(double fontSize) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setDouble('fontSize', fontSize);
  }

  void saveFontWeight(bool isBold) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('fontWeight', isBold);
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

  @override
  void initState() {
    super.initState();
    loadSettings(); // Load settings on start
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
          // Add other settings options here
        ],
      ),
    );
  }
}
