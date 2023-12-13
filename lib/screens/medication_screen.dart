import 'package:flutter/material.dart';
import 'medication_form.dart';
import 'medication_edit_form.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'font_size_notifier.dart'; // Ensure this is correctly imported

class MedicationScreen extends StatefulWidget {
  @override
  _MedicationScreenState createState() => _MedicationScreenState();
}

class _MedicationScreenState extends State<MedicationScreen> {
  final _medsCollection = FirebaseFirestore.instance.collection('medications');
  final _auth = FirebaseAuth.instance;
  Stream<List<Map<String, dynamic>>?> medicationsStream = Stream.value([]);

  @override
  void initState() {
    super.initState();
    medicationsStream = listenToMedications();
  }

  Stream<List<Map<String, dynamic>>> listenToMedications() {
    final user = _auth.currentUser;
    final uId = user?.uid;

    if (uId != null) {
      return _medsCollection.doc(uId).snapshots().map((doc) {
        if (doc.exists) {
          final List medsFromDB =
              (doc.data() as Map<String, dynamic>)['medicationsList'] ?? [];
          return List<Map<String, dynamic>>.from(medsFromDB);
        } else {
          return [];
        }
      });
    } else {
      return Stream.value([]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fontSize =
        Provider.of<FontSizeNotifier>(context).fontSize; // Fetch font size

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: Text('Medications', style: TextStyle(fontSize: fontSize,color:const Color.fromARGB(255, 30, 71, 104), )),
        centerTitle: true,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: const Color.fromARGB(255, 30, 71, 104)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "My Medications",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: fontSize+5 , fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            buildAddMedicationButton(context, fontSize),
            const SizedBox(height: 32),
            Expanded(
              child: buildMedicationsList(context, fontSize),
            ),
          ],
        ),
      ),
    );
  }

  ElevatedButton buildAddMedicationButton(
      BuildContext context, double fontSize) {
    return ElevatedButton(
      onPressed: () async {
        final user = _auth.currentUser;
        final uId = user?.uid;

        if (uId != null) {
          final userDocRef = _medsCollection.doc(uId);
          final documentSnapshot = await userDocRef.get();
          if (!documentSnapshot.exists) {
            await userDocRef.set({});
          }
        }
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MedicationFormScreen()),
        ).then((value) {
          if (value == true) {
            setState(() {});
          }
        });
      },
      child: Text("Add a Medication", style: TextStyle(fontSize: fontSize)),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.all(16),
        textStyle: TextStyle(fontSize: fontSize), primary: const Color.fromARGB(255, 30, 71, 104),
        shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
      ),
    );
  }

  StreamBuilder<List<Map<String, dynamic>>?> buildMedicationsList(
      BuildContext context, double fontSize) {
    return StreamBuilder<List<Map<String, dynamic>>?>(
      stream: medicationsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
              child: Text('Loading...', style: TextStyle(fontSize: fontSize)));
        } else if (snapshot.hasError) {
          return Center(
              child: Text('Error: ${snapshot.error}',
                  style: TextStyle(fontSize: fontSize)));
        } else {
          final medications = snapshot.data ?? [];
          return ListView.builder(
            itemCount: medications.length,
            itemBuilder: (context, index) {
              return buildMedicationCard(medications, index, context, fontSize);
            },
          );
        }
      },
    );
  }

  Card buildMedicationCard(List<Map<String, dynamic>> medications, int index,
      BuildContext context, double fontSize) {
    return Card(
      elevation: 4,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const SizedBox(height: 12),
          ListTile(
            leading: Icon(Icons.medication_outlined,
                color: const Color.fromARGB(255, 30, 71, 104), size: 30 * fontSize / 16),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(medications[index]['name'],
                    style: TextStyle(fontSize: fontSize * 1.3)),
                IconButton(
                  icon: Icon(Icons.edit, size: 25 * fontSize / 16),
                  onPressed: () {
                    Navigator.of(context)
                        .push(
                      MaterialPageRoute(
                        builder: (context) => MedicationEditForm(
                          existingData: medications[index],
                          index: index,
                        ),
                      ),
                    )
                        .then((value) {
                      if (value == true) {
                        setState(() {});
                      }
                    });
                  },
                )
              ],
            ),
            subtitle: buildMedicationDetails(medications, index, fontSize),
          ),
          const SizedBox(height: 25),
        ],
      ),
    );
  }

  Column buildMedicationDetails(
      List<Map<String, dynamic>> medications, int index, double fontSize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(height: 6),
        const Divider(color: Colors.grey),
        SizedBox(height: 6),
        Text('Quantity: ${medications[index]['quantity'] ?? ''}',
            style: TextStyle(fontSize: fontSize)),
        SizedBox(height: 6),
        const Divider(color: Colors.grey),
        SizedBox(height: 6),
        Text('How Often: ${medications[index]['frequency'] ?? ''}',
            style: TextStyle(fontSize: fontSize)),
        SizedBox(height: 6),
        const Divider(color: Colors.grey),
        SizedBox(height: 6),
        Text(
            'Instructions: ${medications[index]['intakeInstructions'].join(", ")}',
            style: TextStyle(fontSize: fontSize)),
      ],
    );
  }
}
