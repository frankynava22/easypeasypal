import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:animations/animations.dart'; // Import the animations package

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
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> _events = [];
  List<Map<String, dynamic>> _allEvents = [];
  List<Map<String, dynamic>> _filteredEvents = [];
  double _opacity = 0.0;
  int _selectedDay = 0;

  @override
  void initState() {
    super.initState();
    _loadUserEvents();
    _animateIn();
  }

  void _animateIn() {
    Future.delayed(Duration(milliseconds: 100), () {
      setState(() {
        _opacity = 1.0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Appointments',
          style: TextStyle(color: const Color.fromARGB(255, 30, 71, 104), fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: const Color.fromARGB(255, 30, 71, 104)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(top: 15, right: 15),
            child: Text(
              DateFormat('dd-MM-yyyy').format(_selectedDate),
              style: TextStyle(fontSize: 20.0, color: const Color.fromARGB(255, 30, 71, 104)),
            ),
          ),
        ],
      ),
      body: _loadUserEventsWidget(),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  _selectedDay = 0;
                  setState(() {
                    _isWeekView = false;
                  });
                  _loadUserEvents(); // Reload events when switching to the Events view
                },
                child: Text('ALL Events'),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
                    if (_selectedDay == 0) {
                      return const Color.fromARGB(255, 79, 132, 176); // Highlight
                    } else {
                      return const Color.fromARGB(255, 30, 71, 104); // Default
                    }
                  }),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                ),
              ),

              FloatingActionButton(
                onPressed: () async {
                  
                  _showEventSetupDialog(context);
                },
                child: Icon(Icons.add),
                backgroundColor: const Color.fromARGB(255, 30, 71, 104),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 32.0),
                child: IconButton(
                  icon: Icon(
                    Icons.calendar_today,
                    color: const Color.fromARGB(255, 30, 71, 104),
                    size: 60.0,
                  ),
                  onPressed: () => _selectDate(context),
                  tooltip: 'Select Date',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _loadUserEventsWidget() {
    return AnimatedOpacity(
      opacity: _opacity,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 16.0, bottom: 8.0),
            child: Text(
              'Events for ${DateFormat('MMMM yyyy').format(_selectedDate)}',
              style: TextStyle(
                fontSize: 20.0,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 8.0),
            child: Wrap(
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
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: _events.isNotEmpty
                  ? ListView.builder(
                      itemCount: _events.length,
                      itemBuilder: (context, index) {
                        final event = _events[index];
                        final eventTitle = event['title'] ?? '';
                        final eventDate =
                            DateFormat('MM-dd-yyyy').format(event['date'].toDate());

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
                            color: Color.fromARGB(255, 234, 242, 250),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: ListTile(
                              title: Text(eventTitle),
                              subtitle: Text(eventDate),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit),
                                    color: const Color.fromARGB(255, 30, 71, 104),
                                    onPressed: () {
                                      _editEvent(event);
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete),
                                    color: const Color.fromARGB(255, 30, 71, 104),
                                    onPressed: () {
                                      _deleteEvent(eventTitle);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Text(
                        'No events found',
                        style: TextStyle(
                          color: const Color.fromARGB(255, 30, 71, 104),
                          fontSize: 20,
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayFilterButton(String day, int dayOfWeek) {
  return ElevatedButton(
    onPressed: () {
      setState(() {
        if (dayOfWeek == -1) {
          // -1 represents the "All Events" button
          _selectedDay = -1;
        } else {
          _selectedDay = dayOfWeek;
          _filterEventsByDay(dayOfWeek);
        }
      });
    },
    child: Text(day),
    style: ElevatedButton.styleFrom(
      backgroundColor: dayOfWeek == _selectedDay || (dayOfWeek == -1 && _selectedDay == null)
          ? Color.fromARGB(255, 79, 132, 176) // Highlighted color
          : Color.fromARGB(255, 30, 71, 104), // Default color
      padding: EdgeInsets.symmetric(horizontal: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
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
              Text(DateFormat('dd-MM-yyyy').format(_selectedDate)),
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
