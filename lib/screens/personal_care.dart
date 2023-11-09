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

  String _bloodType = '';
  String _weight = '';
  String _bloodPressure = '';
  String _allergies = '';
  String _healthGoals = ' ';
  String _generalFeelings = ' ';
  double _weightInPounds = 0.0;
  int _heightFeet = 0;
  int _heightInches = 0;
  double _bmi = 0.0;
  String _bmiCategory = '';
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
          Container(
            margin: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: Colors.teal,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(30),
            ),
            child: TextButton(
              child: Text(
                'Save changes',
                style: TextStyle(
                  color: Colors.teal,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                _savePersonalCareData();
              },
            ),
          )
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
                    _buildEditableCard('Blood Type', _bloodType, Icons.opacity),
                    _buildBMICard(),
                    _buildEditableCard('Weight', _weight, Icons.fitness_center),
                    _buildEditableCard(
                        'Blood Pressure', _bloodPressure, Icons.favorite),
                    _buildLargeEditableCard(
                        'Allergies', _allergies, Icons.nature_people),
                    _buildEditableCard(
                        'Health Goals', _healthGoals, Icons.track_changes),
                    _buildLargeEditableCard(
                        'General Feelings', _generalFeelings, Icons.mood),
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


  Widget _buildEditableCard(String title, String value, IconData icon,
      [String? tooltipMessage]) {
    return InkWell(
        onTap: () {
          _showEditDialog(title, value);
        },
        child: Tooltip(
          message: tooltipMessage ?? '',
          child: _buildMetricCard(title, value, icon),
        ));
  }

  void _showEditDialog(String title, String currentValue) {
    TextEditingController _controller =
        TextEditingController(text: currentValue);
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
               
                String? tooltipMessage;
                if (title == 'Blood Pressure') {
                  tooltipMessage = getBloodPressureTooltip(_controller.text);
                }

                
                if (tooltipMessage != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(tooltipMessage),
                      duration: Duration(seconds: 8),
                    ),
                  );
                } 
               
                  setState(() {
                    switch (title) {
                      case 'Blood Type':
                        _bloodType = _controller.text;
                        break;
                      case 'Weight':
                        double? newWeight = double.tryParse(_controller.text);
                        if (newWeight != null) {
                          _weightInPounds = newWeight;
                          _weight = _weightInPounds.toString();
                        
                          _bmi = calculateBMI(
                              _weightInPounds, _heightFeet, _heightInches);
                          _bmiCategory = getBMICategory(_bmi);
                        }
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
                      case 'Allergies':
                        _allergies = _controller.text;
                        break;
                    }
                  });

                
                  _savePersonalCareData();

             
                  Navigator.of(context).pop();
                
              },
            ),
          ],
        );
      },
    );
  }

  String? getBloodPressureTooltip(String bloodPressureValue) {
    final bpValues = bloodPressureValue.split('/');
    if (bpValues.length == 2) {
      final systolic = int.tryParse(bpValues[0]);
      final diastolic = int.tryParse(bpValues[1]);
      if (systolic != null && diastolic != null) {
        if (systolic < 90 || diastolic < 60) {
          return 'This reading might indicate low blood pressure. Consult a healthcare professional.';
        } else if (systolic > 120 || diastolic > 80) {
          return 'This reading might indicate high blood pressure. Consult a healthcare professional.';
        }
      }
    }
    return null;
  }

  double calculateBMI(double weightInPounds, int heightFeet, int heightInches) {
    int totalHighetInInches = (heightFeet * 12) + heightInches;
    return (weightInPounds / (totalHighetInInches * totalHighetInInches)) * 703;
  }

  String getBMICategory(double bmi) {
    if (bmi < 18.5) {
      return "Underweight";
    } else if (bmi >= 18.5 && bmi < 24.9) {
      return "Normal weight";
    } else if (bmi >= 25 && bmi < 29.9) {
      return "Overweight";
    } else {
      return "Obesity";
    }
  }

 Widget _buildBMICard() {
  String? bmiTooltipMessage = getBMITooltip(_bmiCategory);
  return Tooltip(
    message: bmiTooltipMessage ?? '',
    child: Card(
      elevation: 5,
      margin: EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(20),
        leading: Icon(
          Icons.scale_outlined,
          size: 40,
          color: Colors.teal,
        ),
        title: Text('BMI', style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          _bmi != null
              ? "${_bmi.toStringAsFixed(2)} ($_bmiCategory)"
              : 'Please enter your weight and height',
          style: TextStyle(fontSize: 18),
        ),
        trailing: Icon(
          Icons.edit,
          color: Colors.blueGrey,
        ),
        onTap: () {
          _showBMIEditDialog();
        },
      ),
    ),
  );
}
String? getBMITooltip(String bmiCategory) {
  switch (bmiCategory) {
    case "Underweight":
      return 'Being underweight can be a sign of health problems. It’s important to eat a balanced diet and see a healthcare professional.';
    case "Normal weight":
      return 'You have a normal body weight. Good job! Continue to maintain a healthy diet and regular physical activity.';
    case "Overweight":
      return 'Being overweight is a common health issue. Consider a healthy diet and increasing physical activity to lose weight.';
    case "Obesity":
      return 'Obesity is linked to serious health conditions. It’s important to see a healthcare professional for guidance on achieving a healthier weight.';
    default:
      return null;
  }
}
void _showBMIEditDialog() {
  TextEditingController weightController = TextEditingController(text: _weight.toString());
  TextEditingController heightFeetController = TextEditingController(text: _heightFeet.toString());
  TextEditingController heightInchesController = TextEditingController(text: _heightInches.toString());

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Edit BMI'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: weightController,
              decoration: InputDecoration(
                labelText: 'Weight (in pounds)',
                hintText: 'Enter your weight',
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            TextField(
              controller: heightFeetController,
              decoration: InputDecoration(
                labelText: 'Height (feet)',
                hintText: 'Enter your height in feet',
              ),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: heightInchesController,
              decoration: InputDecoration(
                labelText: 'Height (inches)',
                hintText: 'Enter your height in inches',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
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
              
              double? newWeight = double.tryParse(weightController.text);
              int? newHeightFeet = int.tryParse(heightFeetController.text);
              int? newHeightInches = int.tryParse(heightInchesController.text);

             
              if (newWeight != null && newHeightFeet != null && newHeightInches != null) {
                setState(() {
                  _weightInPounds = newWeight;
                  _heightFeet = newHeightFeet;
                  _heightInches = newHeightInches;
                  _bmi = calculateBMI(_weightInPounds, _heightFeet, _heightInches);
                  _bmiCategory = getBMICategory(_bmi);
                });

               
                _savePersonalCareData();

                
                Navigator.of(context).pop();
              } else {
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Please enter valid numbers for weight and height.'),
                    duration: Duration(seconds: 5),
                  ),
                );
              }
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
        _showEditDialog(title, value);
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
        'bloodType': _bloodType,
        'weight': _weight,
        'bloodPressure': _bloodPressure,
        'healthGoals': _healthGoals,
        'generalFeelings': _generalFeelings,
        'allergies': _allergies,
        'bmi': _bmi,
        'bmiCategory': _bmiCategory,
      };

      await _firestore
          .collection('users')
          .doc(uid)
          .collection('personal_care')
          .doc('metrics')
          .set(metricsData, SetOptions(merge: true));
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
          _bloodType = metricsData['bloodType'] ?? '';
          _weight = metricsData['weight'] ?? '';
          _weightInPounds = double.tryParse(_weight) ?? 0.0;
          _bloodPressure = metricsData['bloodPressure'] ?? '';
          _allergies = metricsData['allergies'] ?? '';
          _healthGoals = metricsData['healthGoals'] ?? '';
          _generalFeelings = metricsData['generalFeelings'] ?? '';
          _bmi = metricsData['bmi'] ?? 0.0;
          _bmiCategory = metricsData['bmiCategory'] ?? '';
        });
      }
    }
  }
}