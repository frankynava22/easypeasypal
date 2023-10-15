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
    List<Map<String, dynamic>> _allEvents = [];
    List<Map<String, dynamic>> _filteredEvents = [];


    @override
    void initState() {
      super.initState();
      _loadUserEvents();
    }

// x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=>>
// x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=   W I D G E T S   =x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=>>
// x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=>>

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
  title: Text('Appointments'),
  centerTitle: true,
  backgroundColor: const Color.fromARGB(255, 30, 71, 104), // Center the title in the middle of the AppBar
  actions: [
    Padding(
      padding: const EdgeInsets.only(top: 15, right: 15), // Add padding on top
      child: Text(
        DateFormat('MM-dd-yyyy').format(_selectedDate),
        style: TextStyle(
          fontSize: 20.0, // Set the font size to a larger value
        ),
      ),
    ),
  ],
)
,

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
                  child: Text('ALL Events',),
                   style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(const Color.fromARGB(255, 30, 71, 104)), // Set the background color of the button to blue
                  ),
                ),
                FloatingActionButton(
                  onPressed: () async{
                    _showEventSetupDialog(context);
                  },
                  child: Icon(Icons.add),
                  backgroundColor: const Color.fromARGB(255, 30, 71, 104),
                  
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 32.0), // Add padding under the calendar button
                    child: IconButton(
                      icon: Icon( Icons.calendar_today,
                                  color: const Color.fromARGB(255, 30, 71, 104), size: 60.0,
                      ),// Set the icon color
                      onPressed: () => _selectDate(context), // Open DatePicker dialog
                      tooltip: 'Select Date',
                    ),
                ),
              ],
            ),
          ],
        ),
      );
  }

// x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=>>

  Widget _loadUserEventsWidget() {
    return Column(
      children: [
        Text('Events for ${DateFormat('MMMM yyyy').format(_selectedDate)}', 
              style: TextStyle(fontSize: 24.0,), // Set the font size to a larger value
            ),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8.0,
          children: [
            // Create buttons to filter events by day of the week
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
          trailing: IconButton(
            icon: Icon(Icons.edit), // Edit icon
            onPressed: () {
              _editEvent(event); // Call a function to edit the event
            },
          ),
        ),
      ),
    );
  },
)

              : Center(
                  child: Text(
                    'No events found',  // Display message when no events found
                    style: TextStyle(
                      color: const Color.fromARGB(255, 30, 71, 104), // Change the text color to blue
                      fontSize: 20,
                    ),
                  ),
                ),
        ),
      ],
    );
  }

// x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=>>

  Widget _buildDayFilterButton(String day, int dayOfWeek) {
  return ElevatedButton(
    onPressed: () {
      _filterEventsByDay(dayOfWeek);
    },
    child: Text(day),
    style: ElevatedButton.styleFrom(
      primary: Color.fromARGB(255, 30, 71, 104),
      padding: EdgeInsets.symmetric(horizontal: 10),
    ),
  );
}


// x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=>>

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
// x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=>>

// x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=>>
// x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=   F  U N C T I O N S   x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=>>
// x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=>>

  void _filterEventsByDay(int dayOfWeek) {
    final filteredEvents = _allEvents.where((event) {
      final eventDate = event['date'].toDate();
      return eventDate.weekday == dayOfWeek;
    }).toList();

    setState(() {
      _filteredEvents = filteredEvents;
      _events = _filteredEvents; // Set _events to filtered events
    });
  }


// x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=>>

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

// x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=>>

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

// x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=>>

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

// x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=>>

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

// x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=>>

  void _loadUserEvents() async {
    final user = _auth.currentUser;
    final userUid = user != null ? user.uid : '';
    final userAppointmentsRef = _firestore.collection('Appointments').doc(userUid);
    final userAppointmentsSnapshot = await userAppointmentsRef.get();

    if (userAppointmentsSnapshot.exists) {
      List<Map<String, dynamic>> events = List<Map<String, dynamic>>.from(userAppointmentsSnapshot.data()!['events']);

      // Sort the events by date from earliest to latest
      events.sort((event1, event2) {
        DateTime date1 = event1['date'].toDate();
        DateTime date2 = event2['date'].toDate();
        return date1.compareTo(date2);
      });

      setState(() {
        _allEvents = events;
        _events = _allEvents; // Initially, set _events to all events
      });
    }
  }

// x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=>>

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

// x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=>>

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

// x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=>>
 
  void _editEvent(Map<String, dynamic> event) {
    // Create a TextEditingController to edit the title
    TextEditingController _editedTitleController = TextEditingController(text: event['title']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Event'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: _editedTitleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                String editedTitle = _editedTitleController.text;
                await _updateEventInFirestore(event, editedTitle);
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

// x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=>>

  Future<void> _updateEventInFirestore(Map<String, dynamic> event, String editedTitle) async {
    final user = _auth.currentUser;
    final userUid = user != null ? user.uid : '';
    final userAppointmentsRef = _firestore.collection('Appointments').doc(userUid);

    final userAppointmentsSnapshot = await userAppointmentsRef.get();
    if (userAppointmentsSnapshot.exists) {
      List<Map<String, dynamic>> userAppointments =
          List<Map<String, dynamic>>.from(userAppointmentsSnapshot.data()!['events']);

      // Find the index of the event that matches the provided event
      final int index = userAppointments.indexWhere((e) => e['title'] == event['title'] && e['date'].toDate() == event['date'].toDate());

      if (index >= 0) {
        // Create a new event with the edited title and the same date as the original event
        Map<String, dynamic> updatedEvent = {
          'title': editedTitle,
          'date': event['date'],
        };

        // Update the event list with the new event
        userAppointments[index] = updatedEvent;

        // Update Firestore with the updated list of events
        await userAppointmentsRef.set({'events': userAppointments});
      }

      // Reload the events list
      _loadUserEvents();
    }
  }
  
// x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=x=>>

}
