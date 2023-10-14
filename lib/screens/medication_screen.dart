import 'package:flutter/material.dart';
import 'medication_form.dart';

class Medication {
  final String name;
  final int quantity;
  final String frequency;
  final List<String> intakeInstructions;

  Medication({
    required this.name,
    required this.quantity,
    required this.frequency,
    required this.intakeInstructions,
  });
}

List<Medication> medications = [
  Medication(
      name: 'Medication 1',
      quantity: 1,
      frequency: '2x daily',
      intakeInstructions: ['on empty stomach', 'after breakfast']),
  Medication(
      name: 'Medication 2',
      quantity: 2,
      frequency: '1x daily',
      intakeInstructions: ['after breakfast']),

  // include route (if it is swallowed, under the tongue, etc...)
  // dosage strength
  // start date and end date + time it should be taken
];

class MedicationScreen extends StatefulWidget {
  @override
  _MedicationScreenState createState() => _MedicationScreenState();
}

class _MedicationScreenState extends State<MedicationScreen> {
  void _addMedication(Medication newMedication) {
    setState(() {
      medications.add(newMedication);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: Text('Go Back'),
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_month),
            onPressed: () {
              // Implement SOS functionality
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Today's Medications",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),

            ElevatedButton(
              onPressed: () {
                // Navigate
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MedicationFormScreen(
                      onMedicationAdded: _addMedication,
                    ),
                  ),
                );
              },
              child: Text("Add a Medication"),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.all(16),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 32), // spacing between button and card

            Expanded(
              child: ListView(
                children: medications.map((medication) {
                  return Card(
                      child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const SizedBox(height: 15),
                      ListTile(
                        leading: Icon(Icons.medication_outlined),
                        title: Text(medication.name,
                            style: TextStyle(fontSize: 21)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(height: 8),
                            Text('Quantity: ${medication.quantity}',
                                style: TextStyle(fontSize: 16)),
                            SizedBox(height: 8),
                            Text('How Often: ${medication.frequency}',
                                style: TextStyle(fontSize: 16)),
                            SizedBox(height: 8),
                            Text(
                                'Intake Instructions: ${medication.intakeInstructions.join(', ')}',
                                style: TextStyle(fontSize: 16)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),
                    ],
                  ));
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
