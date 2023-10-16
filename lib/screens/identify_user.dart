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
        title: Text('Identification'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
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
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              user.email != null ? '${extractFirstName(user.email!)}' : '',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AppointmentsPage(),
                  ),
                );
              },
              child: Text(
                "Appointments",
                style: TextStyle(fontSize: 20),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(300, 60),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CommunicationScreen(),
                  ),
                );
              },
              child: Text(
                "Communication",
                style: TextStyle(fontSize: 20),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(300, 60),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MedicationScreen(),
                  ),
                );
              },
              child: Text(
                "Medication",
                style: TextStyle(fontSize: 20),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(300, 60),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PersonalCareScreen(),
                  ),
                );
              },
              child: Text(
                "Personal Care",
                style: TextStyle(fontSize: 20),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(300, 60),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Add your logic for the fifth button here
              },
              child: Text(
                "Today's Events",
                style: TextStyle(fontSize: 20),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(300, 60),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
