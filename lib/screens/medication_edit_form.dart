import 'package:flutter/material.dart';
import 'medication_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MedicationEditForm extends StatefulWidget {
  final Map<String, dynamic> existingData; // to get map of medication
  final int index;
  //final _firestore = FirebaseFirestore.instance;
  //final String userId;

  MedicationEditForm({
    required this.existingData,
    required this.index,
    //required this.userId,
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
/*
void editMedication(Map<String, dynamic> medication) {
    // Create a TextEditingController to edit the title
    TextEditingController _editedTitleController = TextEditingController(text: medication['name']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Event'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: _editedTitleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                String editedName = _editedTitleController.text;
                await _updateEventInFirestore(medication, editedName);
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }


  Future<void> _updateEventInFirestore(Map<String, dynamic> event, String editedTitle) async {
    final user = _auth.currentUser;
    final userUid = user != null ? user.uid : '';
    final userAppointmentsRef = _medsCollection.doc(userUid);

    final userAppointmentsSnapshot = await userAppointmentsRef.get();
    if (userAppointmentsSnapshot.exists) {
      List<Map<String, dynamic>> userAppointments =
          List<Map<String, dynamic>>.from(userAppointmentsSnapshot.data()!['events']);

      // Find the index of the event that matches the provided event
      final int index = userAppointments.indexWhere((e) => e['title'] == event['title'] && e['date'].toDate() == event['date'].toDate());

      if (index >= 0) {
        // Create a new event with the edited title and the same date as the original event
        Map<String, dynamic> updatedEvent = {
          'title': editedTitle,
          'date': event['date'],
        };

        // Update the event list with the new event
        userAppointments[index] = updatedEvent;

        // Update Firestore with the updated list of events
        await userAppointmentsRef.set({'events': userAppointments});
      }

      // Reload the events list
      _loadUserEvents();
    }
  }
*/

  Future<void> addMedication(Map<String, dynamic> medicationData) async {
    final user = _auth.currentUser;
    final uId = user?.uid;

    if (uId != null) {
      await _medsCollection.doc(uId).update({
        'medicationsList': FieldValue.arrayUnion([medicationData])
      });
    }
  }


  Future<void> updateMedication(Map<String, dynamic> medicationData) async {
    final user = _auth.currentUser;
    final uId = user?.uid;

    /*if (uId != null) {
      await _medsCollection.doc(uId).set({
        'medicationsList': FieldValue.arrayUnion([medicationData])
      }, SetOptions(merge:true));
    }*/
    if (uId != null) {
          //final DocumentSnapshot document = await _medsCollection.doc(uId).get();
      await _medsCollection.doc(uId).update({
        'medicationsList': FieldValue.arrayUnion([medicationData])
      }, );
      



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
                //addMedication(medicationData);
                //currentMedsList.add(medicationData);
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
                  MaterialStateProperty.all(Size(150, 0)), // Set the width here
              padding: MaterialStateProperty.all(
                  EdgeInsets.all(15.0)), // Optional: Adjust padding
            ),
          ),
        ),
      ],
    );
  }
}
