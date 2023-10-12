import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentScreen extends StatefulWidget {
  AppointmentScreen();

  @override
  _AppointmentScreenState createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance; // Initialize Firestore

  // Function to add a new appointment to the "Appointments" collection
  Future<void> addAppointmentToFirestore(String date, String title) async {
    await firestore.collection('Appointments').add({
      'date': date,
      'title': title,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Appointments'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Appointments Screen Content',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Call the function to add an appointment to Firestore
                addAppointmentToFirestore('2023-10-15', 'Sample Appointment');
              },
              child: Text('Add Appointment to Firestore'),
            ),
          ],
        ),
      ),
    );
  }
}
