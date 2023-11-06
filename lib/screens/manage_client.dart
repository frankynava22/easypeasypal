import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ManageClientScreen extends StatefulWidget {
  final String clientUid;

  ManageClientScreen({required this.clientUid});

  @override
  _ManageClientScreenState createState() => _ManageClientScreenState();
}

class _ManageClientScreenState extends State<ManageClientScreen> {
  final _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _clientAppointments = [];

  @override
  void initState() {
    super.initState();
    _loadClientAppointments();
  }

  void _loadClientAppointments() async {
    final clientAppointmentsRef = _firestore.collection('Appointments').doc(widget.clientUid);

    final clientAppointmentsSnapshot = await clientAppointmentsRef.get();
    if (clientAppointmentsSnapshot.exists) {
      setState(() {
        _clientAppointments = List<Map<String, dynamic>>.from(clientAppointmentsSnapshot.data()!['events']);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Client Appointments'),backgroundColor: const Color.fromARGB(255, 30, 71, 104),
      ),
      body: _clientAppointments.isEmpty
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
                    subtitle: Text('Date: ${DateFormat('MM-dd-yyyy').format(date)}'),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddAppointmentDialog(context);
        },
        child: Icon(Icons.add),backgroundColor: const Color.fromARGB(255, 30, 71, 104),
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

  Future<void> _saveClientAppointmentToFirestore({required String title, required DateTime date}) async {
    final clientAppointmentsRef = _firestore.collection('Appointments').doc(widget.clientUid);
    List<Map<String, dynamic>> clientAppointments = [];
    final clientAppointmentsSnapshot = await clientAppointmentsRef.get();
    if (clientAppointmentsSnapshot.exists) {
      clientAppointments =
          List<Map<String, dynamic>>.from(clientAppointmentsSnapshot.data()!['events']);
    }
    clientAppointments.add({'title': title, 'date': date.toUtc()});
    await clientAppointmentsRef.set({'events': clientAppointments});
    _loadClientAppointments();
  }
}
