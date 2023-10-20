import 'package:flutter/material.dart';

class PersonalCareScreen extends StatefulWidget {
  @override
  _PersonalCareScreenState createState() => _PersonalCareScreenState();
}

class _PersonalCareScreenState extends State<PersonalCareScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Personal Care', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.teal[100]!, Colors.grey[300]!],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Text(
                  "Wellness Overview",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  children: [
                    _buildMetricCard(
                        'Full Name', 'John Doe', Icons.account_circle),
                    _buildMetricCard('Blood Type', 'O+', Icons.opacity),
                    _buildMetricCard('Weight', '68kg', Icons.fitness_center),
                    _buildMetricCard(
                        'Blood Pressure', '120/80', Icons.favorite),
                    _buildMetricCard(
                        'Dietary Preference', 'Vegetarian', Icons.restaurant),
                    _buildMetricCard(
                        'Activity Level', 'Active', Icons.run_circle),
                    _buildMetricCard(
                        'Health Goals', 'Lose 5kg', Icons.track_changes),
                    _buildMetricCard('General Feelings', 'Good', Icons.mood),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon) {
    return Card(
      elevation: 5,
      margin: EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(20),
        leading: Icon(
          icon,
          size: 40,
          color: Colors.teal,
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value, style: TextStyle(fontSize: 18)),
        trailing: Icon(
          Icons.edit,
          color: Colors.blueGrey,
        ),
      ),
    );
  }
}

