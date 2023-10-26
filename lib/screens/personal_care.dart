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

  String _fullName = 'John Do';
  String _bloodType = 'O+';
  String _weight = '68kg';
  String _bloodPressure = '120/80';
  String _dietaryPreference = 'Vegan';
  String _activityLevel = 'Active';
  String _healthGoals = 'Lose 5kg in 2 months';
  String _generalFeelings = 'Feeling great after starting my new diet!';

  @override
  void initState() {
    super.initState();
    _fetchPersonalCareData();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Personal Care', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _savePersonalCareData,
          ),
        ],
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
                    _buildEditableCard('Full Name', _fullName, Icons.account_circle),
                    _buildEditableCard('Blood Type', _bloodType, Icons.opacity),
                    _buildEditableCard('Weight', _weight, Icons.fitness_center),
                    _buildEditableCard('Blood Pressure', _bloodPressure, Icons.favorite),
                    _buildSelectableCard('Dietary Preference', _dietaryPreference, Icons.restaurant, ['Vegan', 'Vegetarian', 'Non-Vegetarian']),
                    _buildSelectableCard('Activity Level', _activityLevel, Icons.run_circle, ['Active', 'Somewhat Active', 'Calm']),
                    _buildEditableCard('Health Goals', _healthGoals, Icons.track_changes),
                    _buildLargeEditableCard('General Feelings', _generalFeelings, Icons.mood),
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

  Widget _buildSelectableCard(
      String title, String value, IconData icon, List<String> options) {
    return InkWell(
      onTap: () {
        _showOptionsDialog(title, options);
      },
      child: _buildMetricCard(title, value, icon),
    );
  }

  void _showOptionsDialog(String title, List<String> options) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Column(
            children: options
                .map((option) => ListTile(
                      title: Text(option),
                      onTap: () {
                        setState(() {
                          if (title == 'Dietary Preference') {
                            _dietaryPreference = option;
                          } else if (title == 'Activity Level') {
                            _activityLevel = option;
                          }
                        });
                        Navigator.of(context).pop();
                      },
                    ))
                .toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildEditableCard(String title, String value, IconData icon) {
    return InkWell(
      onTap: () {
        
        _showEditDialog(title, value);
      },
      child: _buildMetricCard(title, value, icon),
    );
  }

  void _showEditDialog(String title, String currentValue) {
    TextEditingController _controller = TextEditingController(text: currentValue);
    showDialog(
        context: context,
        builder: (context) {
            return AlertDialog(
                title: Text('Edit $title'),
                content: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                        labelText: title,
                        hintText: 'Enter $title',
                    ),
                ),
                actions: [
                    TextButton(
                        child: Text('Cancel'),
                        onPressed: () {
                            Navigator.of(context).pop();
                        },
                    ),
                    TextButton(
                        child: Text('Save'),
                        onPressed: () {
                            setState(() {
                                switch (title) {
                                    case 'Full Name':
                                        _fullName = _controller.text;
                                        break;
                                    case 'Blood Type':
                                        _bloodType = _controller.text;
                                        break;
                                    case 'Weight':
                                        _weight = _controller.text;
                                        break;
                                    case 'Blood Pressure':
                                        _bloodPressure = _controller.text;
                                        break;
                                    case 'Health Goals':
                                        _healthGoals = _controller.text;
                                        break;
                                    case 'General Feelings':
                                        _generalFeelings = _controller.text;
                                        break;
                                    
                                }
                            });
                            Navigator.of(context).pop();
                        },
                    ),
                ],
            );
        },
    );
}

  Widget _buildLargeEditableCard(String title, String value, IconData icon) {
    return InkWell(
      onTap: () {
        _showEditDialog(title,value);
      },
    child: Card(
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
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(value, style: TextStyle(fontSize: 18)),
        ),
        trailing: Icon(
          Icons.edit,
          color: Colors.blueGrey,
        ),
      ),
    ),
    );
  }


Future<void> _savePersonalCareData() async {
  final uid = _auth.currentUser?.uid;
  if (uid != null) {
    Map<String, dynamic> metricsData = {
      'fullName': _fullName,
      'bloodType': _bloodType,
      'weight': _weight,
      'bloodPressure': _bloodPressure,
      'dietaryPreference': _dietaryPreference,
      'activityLevel': _activityLevel,
      'healthGoals': _healthGoals,
      'generalFeelings': _generalFeelings,
     
    };

    await _firestore.collection('users').doc(uid)
      .collection('personal_care').doc('metrics').set(metricsData, SetOptions(merge: true));
  }
}



 Future<void> _fetchPersonalCareData() async {
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
        final userDocument = await _firestore.collection('users').doc(uid).get();
        final personalCareData = userDocument.data()?['personal_care'];

        if (personalCareData != null) {
            final metricsData = personalCareData['metrics'] ?? {};
            setState(() {
                _fullName = metricsData['fullName'] ?? _fullName;
                _bloodType = metricsData['bloodType'] ?? _bloodType;
                _weight = metricsData['weight'] ?? _weight;
                _bloodPressure = metricsData['bloodPressure'] ?? _bloodPressure;
                _dietaryPreference = metricsData['dietaryPreference'] ?? _dietaryPreference;
                _activityLevel = metricsData['activityLevel'] ?? _activityLevel;
                _healthGoals = metricsData['healthGoals'] ?? _healthGoals;
                _generalFeelings = metricsData['generalFeelings'] ?? _generalFeelings;
            });
        }
    }
}






}
