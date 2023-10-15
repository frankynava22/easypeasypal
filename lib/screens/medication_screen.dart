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
  List<Map<String, dynamic>> medications = [];
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



/*
  @override
  void initState() {
    super.initState();
     
    readMedications();
  
  }
  */
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
              onPressed: () async {
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
            const SizedBox(height: 32), // spacing between button and card
                
                                          Text('passedddata $medications'),

            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: readMedications(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: Text('Loading...'));
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  } else {
                    medications = snapshot.data ?? [];

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
                                title:
                                    /*Text(medications[index]['name'],
                                    style: TextStyle(fontSize: 21)),
                                    */
                                    Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text(medications[index]['name'],
                                        style: TextStyle(fontSize: 21)),
                                    IconButton(
                                        icon: Icon(Icons.edit),
                                        iconSize: 25,
                                        onPressed: () async {



                            
                                      
                                          /*

                                          Navigator.of(context).push(
                                            MaterialPageRoute(builder: (context) => 
                                           MedicationEditForm(existingData: passData))

                                          );
                                          */
                   

                                          /*Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => MedicationEditForm(existingData: medications),
                  ),);*/
                                          


                                        })
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
                                        style: const TextStyle(fontSize: 16)),
                                    SizedBox(height: 6),
                                    const Divider(color: Colors.grey),
                                    SizedBox(height: 6),
                                    Text(
                                        'How Often: ${medications[index]['frequency'] ?? ''}',
                                        style: TextStyle(fontSize: 16)),
                                    SizedBox(height: 6),
                                    const Divider(color: Colors.grey),
                                    SizedBox(height: 6),
                                    Text(
                                        'Instructions: ${medications[index]['intakeInstructions'].join(", ")}',
                                        style: TextStyle(fontSize: 16)),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 25),

                              /*
                                const Divider(color: Colors.grey),
                                const Text('Delete'),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline,
                                          size: 20),
                                      color: Colors.red,
                                      onPressed: () {},
                                    ),
                                  ],
                                )
*/

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
