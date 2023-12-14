import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'font_size_notifier.dart'; 

class MedicationFormScreen extends StatefulWidget {
  @override
  _MedicationFormScreenState createState() => _MedicationFormScreenState();
}

class _MedicationFormScreenState extends State<MedicationFormScreen> {
  final TextEditingController _nameController = TextEditingController();
  int selectedQuantity = 1;
  String selectedFrequency = '1x daily';
  List<String> selectedInstructions = [];
  List<int> quantityOptions = [1, 2, 3, 4];
  List<String> frequencyOptions = ['1x daily', '2x daily', '3x daily'];
  List<String> intakeInstructions = [
    'on empty stomach',
    'before breakfast',
    'after breakfast',
    'before lunch',
    'after lunch',
    'before dinner',
    'after dinner',
  ];
  final _medsCollection = FirebaseFirestore.instance.collection('medications');
  final _auth = FirebaseAuth.instance;

  Future<void> addMedication(Map<String, dynamic> medicationData) async {
    final user = _auth.currentUser;
    final uId = user?.uid;

    if (uId != null) {
      await _medsCollection.doc(uId).update({
        'medicationsList': FieldValue.arrayUnion([medicationData])
      });
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final fontSize = Provider.of<FontSizeNotifier>(context).fontSize;

    return Scaffold(
      appBar: AppBar(
        title: Text('Add a Medication', style: TextStyle(fontSize: fontSize)), backgroundColor: const Color.fromARGB(255, 30, 71, 104),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          buildCard(_nameController, 'Medication Name', fontSize),
          buildQuantityCard(fontSize),
          buildFrequencyCard(fontSize),
          buildIntakeInstructionsCard(fontSize),
        ],
      ),
      persistentFooterButtons: [
        Center(
          child: ElevatedButton(
            onPressed: () async {
              final String name = _nameController.text;

              if (name.isNotEmpty) {
                Map<String, dynamic> medicationData = {
                  'name': name,
                  'quantity': selectedQuantity,
                  'frequency': selectedFrequency,
                  'intakeInstructions': selectedInstructions
                };
                addMedication(medicationData);
                Navigator.pop(context, true);
              }
            },
            child: Text('Save', style: TextStyle(fontSize: fontSize)),
            style: ElevatedButton.styleFrom(
              primary: const Color.fromARGB(255, 30, 71, 104),
              minimumSize: Size(150, 0),
              padding: EdgeInsets.all(15.0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0),),
            ),
          ),
        ),
      ],
    );
  }

  // builds card with passed controller, label, and fontsize 
  Card buildCard(
      TextEditingController controller, String label, double fontSize) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(fontSize: fontSize),
          ),
        ),
      ),
    );
  }

  // builds quantity card 
  Card buildQuantityCard(double fontSize) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Quantity',
                style:
                    TextStyle(fontSize: fontSize, color: Colors.grey.shade600)),
            DropdownButtonFormField(
              value: selectedQuantity,
              items: quantityOptions.map((int option) {
                return DropdownMenuItem<int>(
                  child: Text(option.toString(),
                      style: TextStyle(fontSize: fontSize)),
                  value: option,
                );
              }).toList(),
              onChanged: (int? value) {
                setState(() {
                  selectedQuantity = value ?? 1;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  // builds frequency card 
  Card buildFrequencyCard(double fontSize) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('How often is this medication taken?',
                style:
                    TextStyle(fontSize: fontSize, color: Colors.grey.shade600)),
            DropdownButtonFormField(
              value: selectedFrequency,
              items: frequencyOptions.map((String option) {
                return DropdownMenuItem<String>(
                  child: Text(option, style: TextStyle(fontSize: fontSize)),
                  value: option,
                );
              }).toList(),
              onChanged: (String? value) {
                setState(() {
                  selectedFrequency = value!;
                });
              },
            ),
          ],
        ),
      ),
    );
  }


  // builds instake instructions card 
  Card buildIntakeInstructionsCard(double fontSize) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Choose Intake Instructions that apply:',
                style:
                    TextStyle(fontSize: fontSize, color: Colors.grey.shade600)),
            Column(
              children: intakeInstructions.map((instruction) {
                return CheckboxListTile(
                  title:
                      Text(instruction, style: TextStyle(fontSize: fontSize)),
                  value: selectedInstructions.contains(instruction),
                  onChanged: (value) {
                    setState(() {
                      if (value!) {
                        selectedInstructions.add(instruction);
                      } else {
                        selectedInstructions.remove(instruction);
                      }
                    });
                  }, activeColor: const Color.fromARGB(255, 30, 71, 104),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
