import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'font_size_notifier.dart'; // Import FontSizeNotifier
import 'font_weight_notifier.dart'; // Import FontWeightNotifier
import 'personal_care.dart';
import 'websites.dart';

class PersonalMenuScreen extends StatefulWidget {
  @override
  _PersonalMenuScreenState createState() => _PersonalMenuScreenState();
}

class _PersonalMenuScreenState extends State<PersonalMenuScreen> {
  void _showHelpModal() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          final fontSizeNotifier = Provider.of<FontSizeNotifier>(context);
          final fontWeightNotifier = Provider.of<FontWeightNotifier>(
              context); // Get the current font weight

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _helpTile(
                    icon: Icons.favorite,
                    title: "Health",
                    subtitle: "This button takes you to the health section.",
                    fontSize: fontSizeNotifier.fontSize,
                    fontWeight:
                        fontWeightNotifier.fontWeight), // Apply font weight
                SizedBox(height: 20),
                _helpTile(
                    icon: Icons.person,
                    title: "Websites",
                    subtitle: "This button lets you access various websites.",
                    fontSize: fontSizeNotifier.fontSize,
                    fontWeight:
                        fontWeightNotifier.fontWeight), // Apply font weight
              ],
            ),
          );
        });
  }

  ListTile _helpTile(
      {required IconData icon,
      required String title,
      String? subtitle,
      required double fontSize,
      required FontWeight fontWeight}) {
    return ListTile(
      leading: Icon(icon, size: 35.0, color: Colors.blueGrey[800]),
      title: Text(title,
          style: TextStyle(fontWeight: fontWeight, fontSize: fontSize)),
      subtitle: Text(subtitle ?? '',
          style: TextStyle(fontSize: fontSize, fontWeight: fontWeight)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fontSizeNotifier = Provider.of<FontSizeNotifier>(context);
    final fontWeightNotifier = Provider.of<FontWeightNotifier>(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.blueGrey[900],
        title: Text('Personal Menu',
            style: TextStyle(
                fontSize: fontSizeNotifier.fontSize,
                fontWeight: fontWeightNotifier.fontWeight)),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _menuOption("Health", Icons.favorite, () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => PersonalCareScreen()),
              );
            }, fontSizeNotifier.fontSize, fontWeightNotifier.fontWeight),
            _menuOption("Websites", Icons.person, () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => WebsitesScreen()),
              );
            }, fontSizeNotifier.fontSize, fontWeightNotifier.fontWeight),
            _menuOption("Help", Icons.help_outline, _showHelpModal,
                fontSizeNotifier.fontSize, fontWeightNotifier.fontWeight),
          ],
        ),
      ),
    );
  }

  Widget _menuOption(String title, IconData icon, VoidCallback onTap,
      double fontSize, FontWeight fontWeight) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15.0),
      child: Column(
        children: [
          Text(title,
              style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: fontWeight,
                  color: Colors.blueGrey[800])),
          SizedBox(height: 10.0),
          InkWell(
            onTap: onTap,
            child: Icon(icon, size: 50.0, color: Colors.blueGrey[500]),
          ),
        ],
      ),
    );
  }
}
