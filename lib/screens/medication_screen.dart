import 'package:flutter/material.dart';
import 'medication_form.dart';
import 'medication_edit_form.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'font_size_notifier.dart'; 

class MedicationScreen extends StatefulWidget {
  @override
  _MedicationScreenState createState() => _MedicationScreenState();
}

class _MedicationScreenState extends State<MedicationScreen> {
  // get collection named medications from DB 
  final _medsCollection = FirebaseFirestore.instance.collection('medications');
  final _auth = FirebaseAuth.instance;
  Stream<List<Map<String, dynamic>>?> medicationsStream = Stream.value([]);

  @override
  void initState() {
    super.initState();
    medicationsStream = listenToMedications();
  }


  // function that listens to information on the DB
  Stream<List<Map<String, dynamic>>> listenToMedications() {
    final user = _auth.currentUser;
    final uId = user?.uid;


    // if uid exists 
    if (uId != null) {

      // return document with respective uId
      return _medsCollection.doc(uId).snapshots().map((doc) {

        // if the document exists then get medicationsList which is an array of maps
        // each map containing medication info such as frequency, intakeInstructions, etc...

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

    // fontSize holds whatever value the user has on settings 
    final fontSize =
        Provider.of<FontSizeNotifier>(context).fontSize; 

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
            // call function to build add medication button
            buildAddMedicationButton(context, fontSize),
            const SizedBox(height: 32),
            // call function to build cards with info 
            Expanded(
              child: buildMedicationsList(context, fontSize),
            ),
          ],
        ),
      ),
    );
  }

  // builds add medication button 
  ElevatedButton buildAddMedicationButton(
      BuildContext context, double fontSize) {
    return ElevatedButton(
      // on button pressed
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
        // show medication form screen on button press
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MedicationFormScreen()),
        ).then((value) {
          if (value == true) {
            setState(() {});
          }
        });
      },
      // button format
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


  //  takes medicationsStream and builds the medications list with it so most recent changes are reflected
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


  // creates the card with health icon, medication name, and edit button 
  // then calls function that builds the details of the medication 
  Card buildMedicationCard(List<Map<String, dynamic>> medications, int index,
      BuildContext context, double fontSize) {
    return Card(
      color: Color.fromARGB(255, 234, 242, 250),
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
                    // when edit button pressed then this will go to medication edit form with previous values showing
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

  // column used to arrange meds details (quantity, frequency, intakeInstructions)
  // vertically
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
