import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class IdentifyUserScreen extends StatelessWidget {
  final User user;

  IdentifyUserScreen({required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Identification'),
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
              'Successfully logged in as:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              user.email ?? "", // Use the user's email here
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Add your logic for the first button here
              },
              child: Text(
                "Appointments",
                style: TextStyle(fontSize: 20), // Set button font size here
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(300, 60), // Set button size here
              ),
            ),
            SizedBox(height: 10), // Add spacing here
            ElevatedButton(
              onPressed: () {
                // Add your logic for the second button here
              },
              child: Text(
                "Communication",
                style: TextStyle(fontSize: 20), // Set button font size here
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(300, 60), // Set button size here
              ),
            ),
            SizedBox(height: 10), // Add spacing here
            ElevatedButton(
              onPressed: () {
                // Add your logic for the third button here
              },
              child: Text(
                "Medication",
                style: TextStyle(fontSize: 20), // Set button font size here
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(300, 60), // Set button size here
              ),
            ),
            SizedBox(height: 10), // Add spacing here
            ElevatedButton(
              onPressed: () {
                // Add your logic for the fourth button here
              },
              child: Text(
                "Personal Care",
                style: TextStyle(fontSize: 20), // Set button font size here
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(300, 60), // Set button size here
              ),
            ),
            SizedBox(height: 10), // Add spacing here
            ElevatedButton(
              onPressed: () {
                // Add your logic for the fifth button here
              },
              child: Text(
                "Ask me anything!",
                style: TextStyle(fontSize: 20), // Set button font size here
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(300, 60), // Set button size here
              ),
            ),
          ],
        ),
      ),
    );
  }
}


