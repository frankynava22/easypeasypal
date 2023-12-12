import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:animations/animations.dart';

class PersonalCareScreen extends StatefulWidget {
  @override
  _PersonalCareScreenState createState() => _PersonalCareScreenState();
}

class _PersonalCareScreenState extends State<PersonalCareScreen>with TickerProviderStateMixin {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String _bloodType = '';
  String _weight = '';
  String _bloodPressure = '';
  String _allergies = '';
  String _healthGoals = ' ';
  double _weightInPounds = 0.0;
  int _heightFeet = 0;
  int _heightInches = 0;
  String heightString = '';
  double _bmi = 0.0;
  String _bmiCategory = '';
   late AnimationController _animationController;
  late Animation<double> _slideAnimation;
 @override
  void initState() {
    super.initState();
    _fetchPersonalCareData();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1), 
    );

    _slideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.forward();

    _fetchPersonalCareData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

void _showHealthGoalsReminder() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Reminder"),
        content: Text("Don't forget your health goals:\n\n$_healthGoals"),
        actions: <Widget>[
          TextButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}


 @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Personal Care', style: TextStyle(color: Colors.white)),
      backgroundColor: const Color.fromARGB(255, 30, 71, 104),
    
    ),
    body: FadeTransition(
        opacity: _slideAnimation,
        child:Container(
      decoration: BoxDecoration(
        
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
                  fontWeight: FontWeight.bold, color: const Color.fromARGB(255, 30, 71, 104),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                   _buildWeightAndHeightRow(),
                  _buildBMICard(),
                  _buildEditableCard('Blood Pressure', _bloodPressure, Icons.favorite, getBloodPressureTooltip(_bloodPressure)),
                  _buildEditableCard('Blood Type', _bloodType, Icons.opacity),
                  _buildLargeEditableCard('Allergies', _allergies, Icons.nature_people),
                  _buildEditableCard('Health Goals', _healthGoals, Icons.track_changes),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  ),);
}


  Widget _buildMetricCard(String title, String value, IconData icon, double titleFontSize) {
  return Card(
    elevation: 5,
    margin: EdgeInsets.symmetric(vertical: 10),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15),
    ),
    child: ListTile(
      contentPadding: EdgeInsets.all(20),
      leading: Icon(icon, size: 40, color: const Color.fromARGB(255, 30, 71, 104)),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: titleFontSize)),
      subtitle: Text(value, style: TextStyle(fontSize: 18)),
      trailing: Icon(Icons.edit, color: Colors.blueGrey),
    ),
  );
}


  Widget _buildEditableCard(String title, String value, IconData icon, [String? tooltipMessage, double titleFontSize = 14]) {
    return SlideTransition(
      position: Tween<Offset>(begin: Offset(-1, 0), end: Offset.zero).animate(_animationController),
      child: InkWell(
        onTap: () {
          _showEditDialog(title, value);
        },
        child: Tooltip(
          message: tooltipMessage ?? '',
          child: _buildMetricCard(title, value, icon, titleFontSize),
        ),
      ),
    );
  }


 void _showEditDialog(String title, String currentValue) {
  TextEditingController _controller = TextEditingController(text: currentValue);

  TextEditingController? _heightFeetController;
  TextEditingController? _heightInchesController;

  if (title == 'Height') {
    _heightFeetController = TextEditingController(text: _heightFeet.toString());
    _heightInchesController = TextEditingController(text: _heightInches.toString());
  }

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Edit $title'),
        content: title == 'Height' 
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _heightFeetController,
                  decoration: InputDecoration(labelText: 'Feet'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: _heightInchesController,
                  decoration: InputDecoration(labelText: 'Inches'),
                  keyboardType: TextInputType.number,
                ),
              ],
            )
          : TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: title,
                hintText: 'Enter $title',
              ),
            ),
        actions: <Widget>[
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text('Save'),
            onPressed: () {
              String? warningMessage;
              if (title == 'Blood Pressure') {
                warningMessage = getBloodPressureTooltip(_controller.text);
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
                      _bmi = calculateBMI(_weightInPounds, _heightFeet, _heightInches);
                      _bmiCategory = getBMICategory(_bmi);
                    }
                    break;
                  case 'Blood Pressure':
                    _bloodPressure = _controller.text;
                    break;
                  case 'Height':
                    _heightFeet = int.tryParse(_heightFeetController!.text) ?? 0;
                    _heightInches = int.tryParse(_heightInchesController!.text) ?? 0;
                    heightString = '${_heightFeet}\'${_heightInches}"'; 
                    _bmi = calculateBMI(_weightInPounds, _heightFeet, _heightInches);
                    _bmiCategory = getBMICategory(_bmi);
                    break;
                  case 'Allergies':
                    _allergies = _controller.text;
                    break;
                  case 'Health Goals':
                    _healthGoals = _controller.text;
                    break;
                }
              });

              if (warningMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar( 
                  SnackBar(content: Text(warningMessage))
                );
              }

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
  return SlideTransition(
    position: Tween<Offset>(begin: Offset(-1, 0), end: Offset.zero).animate(_animationController),
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
          color: const Color.fromARGB(255, 30, 71, 104),
        ),
        title: Text('BMI', style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          "${_bmi.toStringAsFixed(2)} ($_bmiCategory)",
          style: TextStyle(fontSize: 18),
        ),
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
            color: const Color.fromARGB(255, 30, 71, 104),
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

Widget _buildWeightAndHeightRow() {
  return Row(
    children: [
      Expanded(
        child: Padding(
          padding: EdgeInsets.only(right: 0.0), 
          child: _buildEditableCard('Weight', _weight, Icons.fitness_center, null, 13.5), 
        ),
      ),
      Expanded(
        child: Padding(
          padding: EdgeInsets.only(left: 5.0), 
          child: _buildEditableCard('Height', heightString, Icons.height, null, 13.5),
        ),
      ),
    ],
  );
}


  Future<void> _savePersonalCareData() async {
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      Map<String, dynamic> metricsData = {
        'bloodType': _bloodType,
        'weight': _weight,
        'heightFeet': _heightFeet,
        'heightInches': _heightInches,
        'bloodPressure': _bloodPressure,
        'healthGoals': _healthGoals,
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
    try {
      final userDocument = await _firestore.collection('users').doc(uid).collection('personal_care').doc('metrics').get();
      final metricsData = userDocument.data() ?? {};

      setState(() {
        _bloodType = metricsData['bloodType'] ?? '';
        _weight = metricsData['weight'] ?? '';
        
        var heightFeet = metricsData['heightFeet'];
        var heightInches = metricsData['heightInches'];
        if (heightFeet is int && heightInches is int) {
          _heightFeet = heightFeet;
          _heightInches = heightInches;
          heightString = "${_heightFeet}'${_heightInches}\"";
        }

        _weightInPounds = double.tryParse(_weight) ?? 0.0;
        _bloodPressure = metricsData['bloodPressure'] ?? '';
        _allergies = metricsData['allergies'] ?? '';
        _healthGoals = metricsData['healthGoals'] ?? '';
        _bmi = metricsData['bmi'] ?? 0.0;
        _bmiCategory = metricsData['bmiCategory'] ?? '';
      });
    } catch (e, s) {
      print("Error fetching data: $e");
      print("Stack trace: $s");
    }
  }
}




}

