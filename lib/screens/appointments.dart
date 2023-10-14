import 'package:flutter/material.dart';

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
  bool _isWeekView = true; // by default, show week view

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Appointments'),
        actions: [
          if (_isWeekView)
            IconButton(
              icon: Icon(Icons.calendar_today),
              onPressed: () => setState(() {
                _isWeekView = false;
                // TODO: Navigate to month view
              }),
              tooltip: 'Month View',
            )
          else
            IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => setState(() {
                _isWeekView = true;
                // TODO: Navigate back to week view
              }),
              tooltip: 'Back to Week View',
            )
        ],
      ),
      body: _isWeekView ? _buildWeekView() : _buildMonthPlaceholder(),
    );
  }

  Widget _buildWeekView() {
    // Here, you can also retrieve dates dynamically instead of hardcoded values
    final daysOfWeek = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
      ),
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () {
            // TODO: Open dialog or navigate to a new screen to add an event to Firestore
          },
          child: Card(
            child: Center(
              child: Text(daysOfWeek[index]),
            ),
          ),
        );
      },
      itemCount: daysOfWeek.length,
    );
  }

  Widget _buildMonthPlaceholder() {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
      ),
      itemBuilder: (context, index) {
        return Card(
          child: Center(
            child: Text(
              // This is just a placeholder representation. In a real app, you'd have to calculate the actual day numbers dynamically.
              (index < 30) ? (index + 1).toString() : '',
            ),
          ),
        );
      },
      itemCount: 35, // 5 weeks x 7 days
    );
  }
}
