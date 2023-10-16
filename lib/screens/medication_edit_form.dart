import 'package:flutter/material.dart';
import 'medication_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MedicationEditForm extends StatefulWidget {
   Map<String, dynamic> existingData; // to get map of medication
  final int index;

  MedicationEditForm({
    required this.existingData,
    required this.index,
  });

  @override
  _MedicationEditFormScreenState createState() =>
      _MedicationEditFormScreenState();
}

class _MedicationEditFormScreenState extends State<MedicationEditForm> {
  final TextEditingController _nameController = TextEditingController();
  int selectedQuantity = 1;
  String selectedFrequency = '1x daily';

  List<String> selectedInstructions = [];

  List<int> quantityOptions = [1, 2, 3, 4];
  List<String> frequencyOptions = [
    '1x daily',
    '2x daily',
    '3x daily',
  ];

  List<String> intakeInstructions = [
    'on empty stomach',
    'before breakfast',
    'after breakfast',
    'before lunch',
    'after lunch',
    'before dinner',
    'after dinner',
  ];
  //List<Map<String, dynamic>> medications = [];
  final _medsCollection = FirebaseFirestore.instance.collection('medications');
  final _auth = FirebaseAuth.instance;


//read data
  Future<List<Map<String, dynamic>>> readMedications() async {
    DocumentSnapshot snapshot =
        await _medsCollection.doc(_auth.currentUser!.uid).get();

    if (snapshot.exists && snapshot.data() != null) {
      List medsFromDB =
          (snapshot.data() as Map<String, dynamic>)['medicationsList'] ?? [];

      return List<Map<String, dynamic>>.from(medsFromDB);
    } else {
      return [];
    }
  }


  Future<void> updateMedication(Map<String, dynamic> medicationData) async {
  final user = _auth.currentUser;
  final uId = user?.uid;

  if (uId != null) {
    List<Map<String, dynamic>> medsList = await readMedications();

    // Assuming you have a unique index for each medication in the list
    int index = widget.index;

    if (index >= 0 && index < medsList.length) {
      medsList[index] = medicationData; // Update the medication data at the specified index

      await _medsCollection.doc(uId).update({
        'medicationsList': medsList, // Update the medicationsList field with the modified list
      });

      // You might want to also update the widget's existingData for consistency
      setState(() {
        widget.existingData = medicationData;
      });
    }
  }
}


  @override
  void initState() {
    super.initState();
    _nameController.text = widget.existingData['name'];
    selectedQuantity = widget.existingData['quantity'];
    selectedFrequency = widget.existingData['frequency'];
    selectedInstructions =
        List<String>.from(widget.existingData['intakeInstructions']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit a Medication'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            elevation: 4, // Adds a shadow to the card
            margin:
                EdgeInsets.only(bottom: 10), // Provides spacing below the card
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Medication Name',
                  labelStyle: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ),
          Card(
            elevation: 4,
            margin: EdgeInsets.only(bottom: 10),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Quantity ',
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                  ),
                  DropdownButtonFormField(
                    value: selectedQuantity,
                    items: quantityOptions.map((int option) {
                      return DropdownMenuItem<int>(
                        child: Text(option.toString()),
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
          ),
          Card(
            elevation: 4,
            margin: EdgeInsets.only(bottom: 10),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'How often is this medication taken?',
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                  ),
                  DropdownButtonFormField(
                    value: selectedFrequency,
                    items: frequencyOptions.map((String option) {
                      return DropdownMenuItem<String>(
                        child: Text(option),
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
          ),
          Card(
            elevation: 4,
            margin: EdgeInsets.only(bottom: 10),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Choose Intake Instructions that apply:',
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                  ),
                  Column(
                    children: intakeInstructions.map((instruction) {
                      return CheckboxListTile(
                        title: Text(instruction),
                        value: selectedInstructions.contains(instruction),
                        onChanged: (value) {
                          setState(() {
                            if (value!) {
                              selectedInstructions.add(instruction);
                            } else {
                              selectedInstructions.remove(instruction);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
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
                
                updateMedication(medicationData);

                Navigator.pop(context, true);
              }
            },
            child: Text(
              'Save',
              style: TextStyle(fontSize: 18),
            ),
            style: ButtonStyle(
              minimumSize:
                  MaterialStateProperty.all(Size(150, 0)), 
              padding: MaterialStateProperty.all(
                  EdgeInsets.all(15.0)), 
            ),
          ),
        ),
      ],
    );
  }
}