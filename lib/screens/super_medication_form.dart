import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SuperMedicationFormScreen extends StatefulWidget {
  final String selectedUserId;

  SuperMedicationFormScreen({required this.selectedUserId});

  @override
  _SuperMedicationFormScreenState createState() =>
      _SuperMedicationFormScreenState();
}

class _SuperMedicationFormScreenState
    extends State<SuperMedicationFormScreen> {
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
    'on an empty stomach',
    'before breakfast',
    'after breakfast',
    'before lunch',
    'after lunch',
    'before dinner',
    'after dinner',
  ];

  final _medsCollection = FirebaseFirestore.instance.collection('medications');
  final _susersCollection = FirebaseFirestore.instance.collection('Susers');
  final _auth = FirebaseAuth.instance;

  Future<void> addMedication(Map<String, dynamic> medicationData) async {
    final user = _auth.currentUser;
    final uId = user?.uid;

    // Check if the user is a super user
    final isSuperUser = await _susersCollection.doc(uId).get().then(
          (snapshot) => snapshot.exists,
        );

    if (uId != null && isSuperUser) {
      // Perform addition to Firestore collection 'medicationList' for super users
      await _medsCollection.doc(widget.selectedUserId).update({
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Medication for User', style: TextStyle(color: Colors.white, fontSize: 17),) ,
        backgroundColor: const Color.fromARGB(255, 30, 71, 104),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            elevation: 4,
            margin: EdgeInsets.only(bottom: 10),
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
                        }, activeColor: const Color.fromARGB(255, 30, 71, 104),
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
                addMedication(medicationData);

                Navigator.pop(context, true);
              }
            },
            child: Text('Save',style: TextStyle(fontSize: 18),),
            style: ElevatedButton.styleFrom(
              primary: const Color.fromARGB(255, 30, 71, 104), // Set the background color
              minimumSize: Size(150, 0),
              padding: EdgeInsets.all(15.0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0),),
            ),
          ),
        ),
      ],
    );
  }
}
