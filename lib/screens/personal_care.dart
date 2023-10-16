import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PersonalCareScreen extends StatefulWidget {
  @override
  _PersonalCareScreenState createState() => _PersonalCareScreenState();
}

class _PersonalCareScreenState extends State<PersonalCareScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String? _weight;
  String? _height;
  String? _bloodPressure;
  String? _bloodSugar;
  String? _notes;

  Stream<DocumentSnapshot> _metricsStream() {
    final userId = _auth.currentUser!.uid;
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('personal_care')
        .doc('metrics')
        .snapshots();
  }

  Future<void> _saveMetricToFirestore(String field, String value) async {
    // ... [This method remains unchanged]
  }

  Future<void> _showMetricDialog({
    required String title,
    required String labelText,
    required Function(String?) onValueChanged,
    TextInputType inputType = TextInputType.text,
    int? maxLines,
  }) async {
    // ... [This method remains unchanged]
  }

  Widget _buildMetricCard(String title, String? value, VoidCallback onTap) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        title: Text(title,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey[800] ?? Colors.blueGrey)),
        subtitle: Text(value ?? "No data",
            style: TextStyle(
                fontSize: 16, color: Colors.blueGrey[500] ?? Colors.blueGrey)),
        trailing: IconButton(
          icon:
              Icon(Icons.edit, color: Colors.blueGrey[500] ?? Colors.blueGrey),
          onPressed: onTap,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Personal Care', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueGrey[900] ?? Colors.blueGrey,
      ),
      backgroundColor: Colors.blueGrey[100] ?? Colors.blueGrey,
      body: StreamBuilder<DocumentSnapshot>(
        stream: _metricsStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return CircularProgressIndicator();

          final docData = snapshot.data!.data() as Map<String, dynamic>;

          return ListView(
            padding: EdgeInsets.symmetric(vertical: 20),
            children: [
              _buildMetricCard(
                'Weight (lb)',
                docData['weight'],
                () => _showMetricDialog(
                  title: "Enter weight (lb)",
                  labelText: 'Weight (lb)',
                  inputType: TextInputType.numberWithOptions(
                      signed: false, decimal: false),
                  onValueChanged: (value) {
                    if (value != null) {
                      _saveMetricToFirestore('weight', value);
                    }
                  },
                ),
              ),
              _buildMetricCard(
                'Height',
                docData['height'],
                () => _showMetricDialog(
                  title: "Enter Height",
                  labelText: "Height (e.g. 5'5)",
                  onValueChanged: (value) {
                    if (value != null) {
                      _saveMetricToFirestore('height', value);
                    }
                  },
                ),
              ),
              _buildMetricCard(
                'Blood Pressure',
                docData['bloodPressure'],
                () => _showMetricDialog(
                  title: "Enter Blood Pressure",
                  labelText: 'e.g. 120/80',
                  onValueChanged: (value) {
                    if (value != null) {
                      _saveMetricToFirestore('bloodPressure', value);
                    }
                  },
                ),
              ),
              _buildMetricCard(
                'Blood Sugar Level (mg/dL)',
                docData['bloodSugar'],
                () => _showMetricDialog(
                  title: "Enter Blood Sugar Level",
                  labelText: 'mg/dL',
                  inputType: TextInputType.numberWithOptions(
                      signed: false, decimal: false),
                  onValueChanged: (value) {
                    if (value != null) {
                      _saveMetricToFirestore('bloodSugar', value);
                    }
                  },
                ),
              ),
              _buildMetricCard(
                'Notes',
                docData['notes'],
                () => _showMetricDialog(
                  title: "Enter Notes",
                  labelText: 'Notes',
                  maxLines: 4,
                  onValueChanged: (value) {
                    if (value != null) {
                      _saveMetricToFirestore('notes', value);
                    }
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
