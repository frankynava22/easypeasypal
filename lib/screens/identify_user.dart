import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'landing_screen.dart';
import 'communication.dart';
import 'medication_screen.dart';
import 'appointments.dart';
import 'personal_care.dart';
import 'settings.dart'; // Importing the new settings page

class IdentifyUserScreen extends StatelessWidget {
  final User user;

  IdentifyUserScreen({required this.user});

  void _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LandingScreen()));
  }

  String extractFirstName(String email) {
    return email
        .split('@')
        .first
        .split('')
        .takeWhile((c) => RegExp(r'[a-zA-Z]').hasMatch(c))
        .join();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.blueGrey[900],
        title: Text('Identification'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: Colors.white60),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white60),
            onPressed: () => _signOut(context),
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Welcome',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey[800],
              ),
            ),
            Text(
              user.email != null ? '${extractFirstName(user.email!)}' : '',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Colors.blueGrey[600],
              ),
            ),
            SizedBox(height: 40),
            ..._buildButtons(context),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildButtons(BuildContext context) {
    return [
      _customElevatedButton("Appointments", () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AppointmentsPage()),
        );
      }),
      _customElevatedButton("Communication", () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CommunicationScreen()),
        );
      }),
      _customElevatedButton("Medication", () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MedicationScreen()),
        );
      }),
      _customElevatedButton("Personal Care", () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PersonalCareScreen()),
        );
      }),
      _customElevatedButton("Today's Events", () {
        // Add your logic for the fifth button here
      }),
    ];
  }

  Widget _customElevatedButton(String text, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(
          text,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        style: ElevatedButton.styleFrom(
          primary: Colors.blueGrey[200],
          onPrimary: Colors.blueGrey[900],
          minimumSize: Size(280, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 5.0,
        ),
      ),
    );
  }
}
