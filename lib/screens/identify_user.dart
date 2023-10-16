import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  Future<List<Map<String, dynamic>>> fetchTodaysAppointments(
      String userId) async {
    CollectionReference appointments =
        FirebaseFirestore.instance.collection('Appointments');
    DateTime now = DateTime.now();
    DateTime startOfDay = DateTime(now.year, now.month, now.day);
    DateTime endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    DocumentSnapshot doc = await appointments.doc(userId).get();

    List<Map<String, dynamic>> todayEvents = [];
    if (doc.exists) {
      List<dynamic> events = doc['events'] ?? [];
      for (var event in events) {
        DateTime eventDate = (event['date'] as Timestamp).toDate();

        if (eventDate.isAfter(startOfDay) && eventDate.isBefore(endOfDay)) {
          todayEvents.add(event);
        }
      }
    }

    return todayEvents;
  }

  Future<List<Map<String, dynamic>>> fetchTodaysMedications(
      String userId) async {
    CollectionReference meds =
        FirebaseFirestore.instance.collection('medications');

    DocumentSnapshot doc = await meds.doc(userId).get();
    if (doc['medicationsList'] != null) {
      return List<Map<String, dynamic>>.from(doc['medicationsList']);
    } else {
      return [];
    }
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
                MaterialPageRoute(
                    builder: (context) =>
                        SettingsPage()), // NEW: Navigating to the SettingsPage
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
              onPressed: () async {
                List<Map<String, dynamic>> appointments =
                    await fetchTodaysAppointments(user.uid);
                List<Map<String, dynamic>> medications =
                    await fetchTodaysMedications(user.uid);

                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Today\'s Events'),
                        content: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Appointments:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              ...appointments.map((event) => Text(
                                  event['title'])), // Only display event title
                              SizedBox(height: 20),
                              Text(
                                'Medications:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              ...medications.map((med) => ListTile(
                                    title: Text(med['name']),
                                    subtitle: Text(
                                        'Frequency: ${med['frequency']} times a day'),
                                  ))
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                            child: Text('Close'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    });
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
