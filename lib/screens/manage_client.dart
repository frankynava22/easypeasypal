import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'super_medication_form.dart';

class ManageClientScreen extends StatefulWidget {
  final String clientUid;

  ManageClientScreen({required this.clientUid});

  @override
  _ManageClientScreenState createState() => _ManageClientScreenState();
}

class _ManageClientScreenState extends State<ManageClientScreen> {
  final _medsCollection = FirebaseFirestore.instance.collection('medications');
  final _auth = FirebaseAuth.instance;

  Stream<List<Map<String, dynamic>>?> medicationsStream = Stream.value([]);
  bool _showAppointments = true; // To toggle between Appointments and Medications

  @override
  void initState() {
    super.initState();
    medicationsStream = listenToMedications();
  }

  Stream<List<Map<String, dynamic>>> listenToMedications() {
    final user = _auth.currentUser;
    final uId = user?.uid;

    if (uId != null) {
      return _medsCollection.doc(uId).snapshots().map((doc) {
        if (doc.exists) {
          final List medsFromDB =
              (doc.data() as Map<String, dynamic>)['medicationsList'] ?? [];

          return List<Map<String, dynamic>>.from(medsFromDB);
        } else {
          return [];
        }
      });
    } else {
      return Stream.value([]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Client'),
        backgroundColor: const Color.fromARGB(255, 30, 71, 104),
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: () {
              setState(() {
                _showAppointments = true;
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.medical_services),
            onPressed: () {
              setState(() {
                _showAppointments = false;
              });
            },
          ),
        ],
      ),
      body: _showAppointments
          ? AppointmentsContent(clientUid: widget.clientUid)
          : MedicationsContent(clientUid: widget.clientUid),
      floatingActionButton: _showAppointments
          ? FloatingActionButton(
              onPressed: () {
                _showAddAppointmentDialog(context);
              },
              child: Icon(Icons.add),
              backgroundColor: const Color.fromARGB(255, 30, 71, 104),
            )
          : ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SuperMedicationFormScreen(selectedUserId: widget.clientUid),
                  ),
                ).then((value) {
                  if (value == true) {
                    setState(() {});
                  }
                });
              },
              child: Text("Add Medication"),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.all(16),
                textStyle: const TextStyle(fontSize: 18),
                primary: const Color.fromARGB(255, 30, 71, 104),
              ),
            ),
    );
  }

  void _showAddAppointmentDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        DateTime selectedDate = DateTime.now();
        TextEditingController _eventTitleController = TextEditingController();

        return AlertDialog(
          title: Text('Add Appointment'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                children: [
                  Text('Date: '),
                  Text(
                    DateFormat('MM-dd-yyyy').format(selectedDate),
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () async {
                      final newDate = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (newDate != null) {
                        setState(() {
                          selectedDate = newDate;
                        });
                      }
                    },
                  ),
                ],
              ),
              TextField(
                controller: _eventTitleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                await _saveClientAppointmentToFirestore(
                  title: _eventTitleController.text,
                  date: selectedDate,
                );
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveClientAppointmentToFirestore(
      {required String title, required DateTime date}) async {
    final clientAppointmentsRef =
        FirebaseFirestore.instance.collection('Appointments').doc(widget.clientUid);
    List<Map<String, dynamic>> clientAppointments = [];
    final clientAppointmentsSnapshot = await clientAppointmentsRef.get();
    if (clientAppointmentsSnapshot.exists) {
      clientAppointments = List<Map<String, dynamic>>.from(
          clientAppointmentsSnapshot.data()!['events']);
    }
    clientAppointments.add({'title': title, 'date': date.toUtc()});
    await clientAppointmentsRef.set({'events': clientAppointments});
  }
}

class MedicationsContent extends StatefulWidget {
  final String clientUid;

  MedicationsContent({required this.clientUid});

  @override
  _MedicationsContentState createState() => _MedicationsContentState();
}

class _MedicationsContentState extends State<MedicationsContent> {
  final _medsCollection = FirebaseFirestore.instance.collection('medications');
  final _auth = FirebaseAuth.instance;

  Stream<List<Map<String, dynamic>>> medicationsStream =
      Stream.value([]); // Initialize with an empty stream

  @override
  void initState() {
    super.initState();
    medicationsStream = listenToMedications(widget.clientUid);
  }

  Stream<List<Map<String, dynamic>>> listenToMedications(String clientUid) {
    // Use the provided clientUid instead of the logged-in user's uid
    return _medsCollection.doc(clientUid).snapshots().map((doc) {
      if (doc.exists) {
        final List medsFromDB =
            (doc.data() as Map<String, dynamic>)['medicationsList'] ?? [];

        return List<Map<String, dynamic>>.from(medsFromDB);
      } else {
        return [];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: medicationsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: Text('Loading Medications...'));
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          final medications = snapshot.data ?? [];

          return medications.isEmpty
              ? Center(
                  child: Text(
                    'No medications found for this client.',
                    style: TextStyle(fontSize: 20),
                  ),
                )
              : ListView.builder(
                  itemCount: medications.length,
                  itemBuilder: (context, index) {
                    final medication = medications[index];
                    final name = medication['name'] ?? '';
                    final quantity = medication['quantity'] ?? '';
                    final frequency = medication['frequency'] ?? '';
                    final intakeInstructions =
                        medication['intakeInstructions']?.join(", ") ?? '';

                    return Card(
                      child: ListTile(
                        title: Text(name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Quantity: $quantity'),
                            Text('Frequency: $frequency'),
                            Text('Instructions: $intakeInstructions'),
                          ],
                        ),
                      ),
                    );
                  },
                );
        }
      },
    );
  }
}

class AppointmentsContent extends StatefulWidget {
  final String clientUid;

  AppointmentsContent({required this.clientUid});

  @override
  _AppointmentsContentState createState() => _AppointmentsContentState();
}

class _AppointmentsContentState extends State<AppointmentsContent> {
  final _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _clientAppointments = [];

  @override
  void initState() {
    super.initState();
    _loadClientAppointments();
  }

  void _loadClientAppointments() {
    final clientAppointmentsRef =
        _firestore.collection('Appointments').doc(widget.clientUid);

    clientAppointmentsRef.snapshots().listen((clientAppointmentsSnapshot) {
      if (clientAppointmentsSnapshot.exists) {
        setState(() {
          _clientAppointments = List<Map<String, dynamic>>.from(
              clientAppointmentsSnapshot.data()!['events']);
        });
      } else {
        setState(() {
          _clientAppointments = [];
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return _clientAppointments.isEmpty
        ? Center(
            child: Text(
              'No appointments found for this client.',
              style: TextStyle(fontSize: 20),
            ),
          )
        : ListView.builder(
            itemCount: _clientAppointments.length,
            itemBuilder: (context, index) {
              final appointment = _clientAppointments[index];
              final title = appointment['title'] ?? '';
              final date = appointment['date'].toDate();

              return Card(
                child: ListTile(
                  title: Text(title),
                  subtitle:
                      Text('Date: ${DateFormat('MM-dd-yyyy').format(date)}'),
                ),
              );
            },
          );
  }
}

