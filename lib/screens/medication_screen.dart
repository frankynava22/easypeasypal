import 'package:flutter/material.dart';
import 'medication_form.dart';
import 'medication_edit_form.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
      // Replace .get() with .snapshots() to listen for changes
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
      // Return an empty stream if the user is not authenticated
      return Stream.value([]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: Text('Go Back'),
      
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
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final user = _auth.currentUser;
                final uId = user?.uid;

                if (uId != null) {
                  final userDocRef = _medsCollection.doc(uId);

                  // Check if the document exists
                  final documentSnapshot = await userDocRef.get();

                  if (!documentSnapshot.exists) {
                    // document doesn't exist, so create a new one
                    await userDocRef.set({});
                  }
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MedicationFormScreen(),
                  ),
                ).then((value) {
                  if (value == true) {
                    setState(() {});
                  }
                });
              },
              child: Text("Add a Medication"),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.all(16),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>?>(
                stream: medicationsStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: Text('Loading...'));
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  } else {
                    final medications = snapshot.data ?? [];

                    return ListView.builder(
                      itemCount: medications.length,
                      itemBuilder: (context, index) {
                        return Card(
                          elevation: 4,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              const SizedBox(height: 12),
                              ListTile(
                                leading: Icon(Icons.medication_outlined,
                                    color: Colors.blue, size: 30),
                                title: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text(medications[index]['name'],
                                        style: TextStyle(fontSize: 21)),
                                    IconButton(
                                      icon: Icon(Icons.edit),
                                      iconSize: 25,
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                MedicationEditForm(
                                              existingData: medications[index],
                                              index: index,
                                            ),
                                          ),
                                        ).then((value) {
                                          if (value == true) {
                                            setState(() {});
                                          }
                                        });
                                      },
                                    )
                                  ],
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    SizedBox(height: 6),
                                    const Divider(color: Colors.grey),
                                    SizedBox(height: 6),
                                    Text(
                                      'Quantity: ${medications[index]['quantity'] ?? ''}',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    SizedBox(height: 6),
                                    const Divider(color: Colors.grey),
                                    SizedBox(height: 6),
                                    Text(
                                      'How Often: ${medications[index]['frequency'] ?? ''}',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    SizedBox(height: 6),
                                    const Divider(color: Colors.grey),
                                    SizedBox(height: 6),
                                    Text(
                                      'Instructions: ${medications[index]['intakeInstructions'].join(", ")}',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 25),
                            ],
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}