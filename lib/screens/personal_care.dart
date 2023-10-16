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

  Future<void> _saveMetricToFirestore(String field, String? value) async {
    try {
      final userId = _auth.currentUser!.uid;
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('personal_care')
          .doc('metrics')
          .set({
        field: value,
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data saved successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving data: $e')),
      );
    }
  }

  Widget _buildMetricTile(String title, String? value, VoidCallback onTap) {
    return ListTile(
      title: Text(title),
      subtitle: Text(value ?? "No value"),
      trailing: IconButton(
        icon: Icon(Icons.edit),
        onPressed: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Personal Care'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _metricsStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return CircularProgressIndicator(); // Loading indicator

          final docData = snapshot.data!.data() as Map<String, dynamic>;

          _weight = docData['weight'];
          _height = docData['height'];
          _bloodPressure = docData['bloodPressure'];
          _bloodSugar = docData['bloodSugar'];
          _notes = docData['notes'];

          return ListView(
            children: [
              _buildMetricTile('Weight (lb)', _weight, () async {
                await showDialog<String>(
                  context: context,
                  builder: (BuildContext context) => SimpleDialog(
                    title: Text("Enter weight (lb)"),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: TextField(
                          keyboardType: TextInputType.numberWithOptions(
                              signed: false, decimal: false),
                          onChanged: (val) {
                            if (int.tryParse(val) != null &&
                                int.tryParse(val)! >= 0) {
                              _weight = val;
                            }
                          },
                          decoration: InputDecoration(labelText: 'Weight (lb)'),
                        ),
                      ),
                      TextButton(
                        child: Text("OK"),
                        onPressed: () {
                          Navigator.pop(context);
                          _saveMetricToFirestore('weight', _weight);
                        },
                      ),
                    ],
                  ),
                );
              }),
              _buildMetricTile('Height', _height, () async {
                await showDialog<String>(
                  context: context,
                  builder: (BuildContext context) => SimpleDialog(
                    title: Text("Enter Height"),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: TextField(
                          onChanged: (val) {
                            _height = val;
                          },
                          decoration: InputDecoration(
                              labelText: "Enter height (e.g. 5'5)"),
                        ),
                      ),
                      TextButton(
                        child: Text("OK"),
                        onPressed: () {
                          Navigator.pop(context);
                          _saveMetricToFirestore('height', _height);
                        },
                      ),
                    ],
                  ),
                );
              }),
              _buildMetricTile('Blood Pressure', _bloodPressure, () async {
                await showDialog<String>(
                  context: context,
                  builder: (BuildContext context) => SimpleDialog(
                    title: Text("Enter Blood Pressure"),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: TextField(
                          onChanged: (val) => _bloodPressure = val,
                          decoration: InputDecoration(labelText: 'e.g. 120/80'),
                        ),
                      ),
                      TextButton(
                        child: Text("OK"),
                        onPressed: () {
                          Navigator.pop(context);
                          _saveMetricToFirestore(
                              'bloodPressure', _bloodPressure);
                        },
                      ),
                    ],
                  ),
                );
              }),
              _buildMetricTile('Blood Sugar Level (mg/dL)', _bloodSugar,
                  () async {
                await showDialog<String>(
                  context: context,
                  builder: (BuildContext context) => SimpleDialog(
                    title: Text("Enter Blood Sugar Level"),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: TextField(
                          keyboardType: TextInputType.numberWithOptions(
                              signed: false, decimal: false),
                          onChanged: (val) {
                            if (int.tryParse(val) != null &&
                                int.tryParse(val)! >= 0) {
                              _bloodSugar = val;
                            }
                          },
                          decoration: InputDecoration(labelText: 'mg/dL'),
                        ),
                      ),
                      TextButton(
                        child: Text("OK"),
                        onPressed: () {
                          Navigator.pop(context);
                          _saveMetricToFirestore('bloodSugar', _bloodSugar);
                        },
                      ),
                    ],
                  ),
                );
              }),
              _buildMetricTile('Notes', _notes, () async {
                await showDialog<String>(
                  context: context,
                  builder: (BuildContext context) => SimpleDialog(
                    title: Text("Enter Notes"),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: TextField(
                          maxLines: 4,
                          onChanged: (val) => _notes = val,
                          decoration: InputDecoration(labelText: 'Notes'),
                        ),
                      ),
                      TextButton(
                        child: Text("OK"),
                        onPressed: () {
                          Navigator.pop(context);
                          _saveMetricToFirestore('notes', _notes);
                        },
                      ),
                    ],
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}
