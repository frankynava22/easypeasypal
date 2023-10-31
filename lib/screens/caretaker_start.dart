import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'landing_screen.dart';
import 'communication.dart';
import 'medication_screen.dart';
import 'appointments.dart';
import 'personal_care.dart';
import 'settings.dart';
import 'caretaker_dash.dart';

class CaretakerStartScreen extends StatefulWidget {
  final User user;

  CaretakerStartScreen({required this.user});

  @override
  _CaretakerStartScreenState createState() => _CaretakerStartScreenState();
}

class _CaretakerStartScreenState extends State<CaretakerStartScreen> {
  List<String> users = [];

  void addUser() {
    setState(() {
      users.add("User ${users.length + 1}");
    });
  }

  void _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => LandingScreen()));
  }

  List<TextEditingController> caretakerIdControllers =
      List.generate(7, (index) => TextEditingController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Caretaker Login'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _signOut(context),
          )
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Caretaker ID:',
            style: TextStyle(fontSize: 20),
          ),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: List.generate(7, (index) {
                return Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 30, // Adjust the width as needed
                        child: TextField(
                          controller: caretakerIdControllers[index],
                          maxLength: 1,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            counterText: '',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      if (index == 6)
                        Text(
                          '-P',
                          style: TextStyle(fontSize: 16),
                        ),
                    ],
                  ),
                );
              }),
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Handle the confirmation action here
              String caretakerId = caretakerIdControllers.map((controller) => controller.text).join('');
              if (caretakerId == '2020202') {
                // If the caretaker ID is 2020202, navigate to the next screen (CaretakerDashboard)
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => CaretakerDashboardScreen()),
                );
              } else {
                // Handle the case when the caretaker ID is not 2020202 (optional)
                print('Invalid caretaker ID. Please try again.');
              }
            },
            child: Text('Confirm'),
          ),
        ],
      ),
    );
  }
}
