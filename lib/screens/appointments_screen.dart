import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentScreen extends StatefulWidget {
  AppointmentScreen();

  @override
  _AppointmentScreenState createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance; // Initialize Firestore
  final CollectionReference appointmentsCollection =
      FirebaseFirestore.instance.collection('Appointments');

  // Function to add a new appointment to the "Appointments" collection
  Future<void> addAppointmentToFirestore(String date, String title) async {
    await appointmentsCollection.add({
      'date': date,
      'title': title,
    });
  }

  // Function to retrieve and print all appointments from the "Appointments" collection
  Future<void> getAppointmentsFromFirestore() async {
    final QuerySnapshot querySnapshot = await appointmentsCollection.get();
    final appointments = querySnapshot.docs;
    
    for (var appointment in appointments) {
      final data = appointment.data() as Map<String, dynamic>;
      if (data.containsKey('date') && data.containsKey('title')) {
        final date = data['date'] as String; // Cast to String
        final title = data['title'] as String; // Cast to String
        print('Date: $date, Title: $title');
      } else {
        print('Invalid document format');
      }
    }
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
            ElevatedButton(
              onPressed: () {
                // Call the function to retrieve and print all appointments
                getAppointmentsFromFirestore();
              },
              child: Text('Retrieve Appointments from Firestore'),
            ),
          ],
        ),
      ),
    );
  }
}
