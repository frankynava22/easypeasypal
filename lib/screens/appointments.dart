import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Appointments',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: AppointmentsPage(),
    );
  }
}

class AppointmentsPage extends StatefulWidget {
  @override
  _AppointmentsPageState createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> {
  TextEditingController _eventTitleController = TextEditingController();
  bool _isWeekView = true;
  DateTime _selectedDate = DateTime.now();
  final _firestore = FirebaseFirestore.instance; // Initialize Firestore
  final _auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> _events = [];

  @override
  void initState() {
    super.initState();
    _loadUserEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  title: Text('Appointments'),
  actions: [
    IconButton(
      icon: Icon(Icons.calendar_today),
      onPressed: () => _selectDate(context), // Open DatePicker dialog
      tooltip: 'Select Date',
    ),
  ],
),

      body:  _loadUserEventsWidget(),
      
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isWeekView = false;
                  });
                  _loadUserEvents(); // Reload events when switching to the Events view
                },
                child: Text('ALL Events'),
              ),
              FloatingActionButton(
                onPressed: () async{
                  _showEventSetupDialog(context);
                },
                child: Icon(Icons.add),
              ),
            ],
          ),
        ],
      ),
    );
  }

  

  Widget _loadUserEventsWidget() {
  return Column(
    children: [
      Text('Events for ${DateFormat('MMMM yyyy').format(_selectedDate)}'),
      Wrap(
        alignment: WrapAlignment.center,
        spacing: 8.0,
        children: [
          _buildDayFilterButton('Mon', DateTime.monday),
          _buildDayFilterButton('Tue', DateTime.tuesday),
          _buildDayFilterButton('Wed', DateTime.wednesday),
          _buildDayFilterButton('Thu', DateTime.thursday),
          _buildDayFilterButton('Fri', DateTime.friday),
          _buildDayFilterButton('Sat', DateTime.saturday),
          _buildDayFilterButton('Sun', DateTime.sunday),
        ],
      ),
      Expanded(
        child: _events.isNotEmpty
            ? ListView.builder(
                itemCount: _events.length,
                itemBuilder: (context, index) {
                  final event = _events[index];
                  final eventTitle = event['title'] ?? '';
                  final eventDate = DateFormat('MM-dd-yyyy').format(event['date'].toDate());

                  return Dismissible(
                    key: Key(eventTitle),
                    onDismissed: (direction) {
                      _deleteEvent(eventTitle);
                    },
                    background: Container(
                      color: Colors.red,
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(
                            Icons.delete,
                            color: Colors.white,
                            size: 36,
                          ),
                          Text(
                            "Delete",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    child: Card(
                      child: ListTile(
                        title: Text(eventTitle),
                        subtitle: Text(eventDate),
                      ),
                    ),
                  );
                },
              )
            : Center(
                child: Text(
                  'No events found',
                  style: TextStyle(
                    color: Colors.blue, // Change the text color to red
                    fontSize: 20,
                  ),
                ),
              ),
      ),
    ],
  );
}


Widget _buildDayFilterButton(String day, int dayOfWeek) {
  return ElevatedButton(
    onPressed: () {
      _filterEventsByDay(dayOfWeek);
    },
    child: Text(day),
    style: ElevatedButton.styleFrom(
      primary: Colors.blue,
      padding: EdgeInsets.symmetric(horizontal: 10),
    ),
  );
}

void _filterEventsByDay(int dayOfWeek) {
  final filteredEvents = _events.where((event) {
    final eventDate = event['date'].toDate();
    return eventDate.weekday == dayOfWeek;
  }).toList();

  setState(() {
    _events = filteredEvents;
  });
}




  Widget _buildDatePickerButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        final selectedDate = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),
          initialDatePickerMode: DatePickerMode.day,
        );

        if (selectedDate != null) {
          setState(() {
            _selectedDate = selectedDate;
          });
          _loadUserEvents(); // Reload events for the selected date
        }
      },
      child: Text('Select Date'),
    );
  }

  void _showEventSetupDialog(BuildContext context) async {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Set Up Event'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(DateFormat('MM-dd-yyyy').format(_selectedDate)),
            TextField(
              controller: _eventTitleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () async {
              await _saveEventToFirestore(
                title: _eventTitleController.text,
                date: _selectedDate,
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
Future<void> _selectDate(BuildContext context) async {
  final selectedDate = await showDatePicker(
    context: context,
    initialDate: _selectedDate,
    firstDate: DateTime(2000),
    lastDate: DateTime(2101),
    initialDatePickerMode: DatePickerMode.day,
  );

  if (selectedDate != null) {
    setState(() {
      _selectedDate = selectedDate;
    });
    _loadUserEventsForSelectedDate(); // Load events for the selected date
  }
}

void _loadUserEventsForSelectedDate() async {
  final user = _auth.currentUser;
  final userUid = user != null ? user.uid : '';
  final userAppointmentsRef = _firestore.collection('Appointments').doc(userUid);

  final userAppointmentsSnapshot = await userAppointmentsRef.get();
  if (userAppointmentsSnapshot.exists) {
    setState(() {
      _events = List<Map<String, dynamic>>.from(userAppointmentsSnapshot.data()!['events']);
    });
    _filterEventsBySelectedDate(); // Filter events for the selected date
  }
}

void _filterEventsBySelectedDate() {
  final filteredEvents = _events.where((event) {
    final eventDate = event['date'].toDate();
    return eventDate.year == _selectedDate.year &&
        eventDate.month == _selectedDate.month &&
        eventDate.day == _selectedDate.day;
  }).toList();

  setState(() {
    _events = filteredEvents;
  });
}
  Future<void> _saveEventToFirestore(
      {required String title, required DateTime date}) async {
    final user = _auth.currentUser;
    final userUid = user != null ? user.uid : '';
    final userAppointmentsRef =
        _firestore.collection('Appointments').doc(userUid);

    List<Map<String, dynamic>> userAppointments = [];
    final userAppointmentsSnapshot = await userAppointmentsRef.get();
    if (userAppointmentsSnapshot.exists) {
      userAppointments =
          List<Map<String, dynamic>>.from(userAppointmentsSnapshot.data()!['events']);
    }

    userAppointments.add({'title': title, 'date': date.toUtc()});

    await userAppointmentsRef.set({'events': userAppointments});
    _loadUserEvents(); // Reload events after saving a new event
  }

  void _loadUserEvents() async {
    final user = _auth.currentUser;
    final userUid = user != null ? user.uid : '';
    final userAppointmentsRef =
        _firestore.collection('Appointments').doc(userUid);

    final userAppointmentsSnapshot = await userAppointmentsRef.get();
    if (userAppointmentsSnapshot.exists) {
      setState(() {
        _events =
            List<Map<String, dynamic>>.from(userAppointmentsSnapshot.data()!['events']);
      });
    }
  }

  void _deleteEvent(String title) async {
    final user = _auth.currentUser;
    final userUid = user != null ? user.uid : '';
    final userAppointmentsRef = _firestore.collection('Appointments').doc(userUid);

    List<Map<String, dynamic>> userAppointments = [];
    final userAppointmentsSnapshot = await userAppointmentsRef.get();
    if (userAppointmentsSnapshot.exists) {
      userAppointments =
          List<Map<String, dynamic>>.from(userAppointmentsSnapshot.data()!['events']);
    }

    // Find and remove the event with the specified title
    userAppointments.removeWhere((event) => event['title'] == title);

    // Update Firestore with the updated list of events
    await userAppointmentsRef.set({'events': userAppointments});

    // Refresh the events list
    _loadUserEvents();
  }
}
