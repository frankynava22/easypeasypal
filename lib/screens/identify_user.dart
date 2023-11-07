import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'font_size_notifier.dart';
import 'font_weight_notifier.dart'; // Import FontWeightNotifier
import 'landing_screen.dart';
import 'communication.dart';
import 'medication_screen.dart';
import 'appointments.dart';
import 'personal_care.dart';
import 'settings.dart';

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
    final fontSize = Provider.of<FontSizeNotifier>(context)
        .fontSize; // Get the current font size
    final fontWeight = Provider.of<FontWeightNotifier>(context)
        .fontWeight; // Get the current font weight

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Identification',
          style: TextStyle(
              fontSize: fontSize,
              fontWeight: fontWeight), // Apply dynamic font size and weight
        ),
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
                fontSize: fontSize * 1.5, // Scale font size
                fontWeight: fontWeight, // Apply dynamic font weight
              ),
            ),
            Text(
              user.email != null ? '${extractFirstName(user.email!)}' : '',
              style: TextStyle(
                fontSize: fontSize * 1.2, // Scale font size
                fontWeight: fontWeight, // Apply dynamic font weight
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AppointmentsPage()),
                );
              },
              child: Text("Appointments",
                  style: TextStyle(fontSize: fontSize, fontWeight: fontWeight)),
              style: ElevatedButton.styleFrom(minimumSize: Size(300, 60)),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CommunicationScreen()),
                );
              },
              child: Text("Communication",
                  style: TextStyle(fontSize: fontSize, fontWeight: fontWeight)),
              style: ElevatedButton.styleFrom(minimumSize: Size(300, 60)),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MedicationScreen()),
                );
              },
              child: Text("Medication",
                  style: TextStyle(fontSize: fontSize, fontWeight: fontWeight)),
              style: ElevatedButton.styleFrom(minimumSize: Size(300, 60)),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PersonalCareScreen()),
                );
              },
              child: Text("Personal Care",
                  style: TextStyle(fontSize: fontSize, fontWeight: fontWeight)),
              style: ElevatedButton.styleFrom(minimumSize: Size(300, 60)),
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
                        title: Text('Today\'s Events',
                            style: TextStyle(
                                fontSize: fontSize, fontWeight: fontWeight)),
                        content: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Appointments:',
                                style: TextStyle(
                                    fontWeight: fontWeight, fontSize: fontSize),
                              ),
                              ...appointments.map((event) => ListTile(
                                    title: Text(event['title'],
                                        style: TextStyle(
                                            fontSize: fontSize,
                                            fontWeight: fontWeight)),
                                    subtitle: Text(
                                        '${event['date'].toDate().hour}:${event['date'].toDate().minute}',
                                        style: TextStyle(
                                            fontSize: fontSize,
                                            fontWeight: fontWeight)),
                                  )),
                              SizedBox(height: 20),
                              Text(
                                'Medications:',
                                style: TextStyle(
                                    fontWeight: fontWeight, fontSize: fontSize),
                              ),
                              ...medications.map((med) => ListTile(
                                    title: Text(med['name'],
                                        style: TextStyle(
                                            fontSize: fontSize,
                                            fontWeight: fontWeight)),
                                    subtitle: Text(
                                        'Frequency: ${med['frequency']} times a day',
                                        style: TextStyle(
                                            fontSize: fontSize,
                                            fontWeight: fontWeight)),
                                  ))
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                            child: Text('Close',
                                style: TextStyle(
                                    fontSize: fontSize,
                                    fontWeight: fontWeight)),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    });
              },
              child: Text("Today's Events",
                  style: TextStyle(fontSize: fontSize, fontWeight: fontWeight)),
              style: ElevatedButton.styleFrom(minimumSize: Size(300, 60)),
            ),
          ],
        ),
      ),
    );
  }
}
