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
    final boldTextNotifier = Provider.of<BoldTextNotifier>(context);
    final fontSizeNotifier = Provider.of<FontSizeNotifier>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text("Dark Theme",
                style: Theme.of(context).textTheme.bodyLarge),
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
          const Divider(color: Colors.grey),
          /*Text('Text Size: $_currentSliderValue',style: Theme.of(context).textTheme.bodyLarge), 

          Slider(value: _currentSliderValue,
          min: 15.0,
          max: 24.0,
          divisions: 3,
          
           onChanged: (double value) {
            setState(() {
              _currentSliderValue = value; 
            });
            Provider.of<FontSizeNotifier>(context).setFontSize(value);

           },
           
           ),*/

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 15.0
            ),
            child: Text('Size of Text:  ${fontSizeNotifier.fontSize}',
                style: Theme.of(context).textTheme.bodyLarge),
          ),

           Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0
            ),
            child: Text('SubText Test',
                style: Theme.of(context).textTheme.bodySmall),
          ),


          //Text('Size of Text: ${fontSizeNotifier.fontSize}',style: Theme.of(context).textTheme.bodyLarge),
          //Text('Subtext Test: ${fontSizeNotifier.fontSize}',style: Theme.of(context).textTheme.bodySmall),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Slider(
              value: fontSizeNotifier.fontSize,
              min: 15.0,
              max: 24.0,
              divisions: 3,
              onChanged: (double value) {
                fontSizeNotifier.setFontSize(value);
              },
            ),
          ),

/*
           Slider(value: fontSizeNotifier.fontSize,
           min:15.0,
           max:24.0,
           divisions: 3,
           onChanged: (double value){
            fontSizeNotifier.setFontSize(value); 
           },),
*/

          //bold text
          const Divider(color: Colors.grey),

          SwitchListTile(
            title:
                Text("Bold Text", style: Theme.of(context).textTheme.bodyLarge),
            value: boldTextNotifier.isBold,
            onChanged: (bool value) {
              boldTextNotifier.setBold(value);
            },
          ),
        ],
      ),
    );
  }
}
