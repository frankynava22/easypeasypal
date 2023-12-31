import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'font_size_notifier.dart';
import 'font_weight_notifier.dart';
import 'landing_screen.dart';
import 'communication.dart';
import 'medication_screen.dart';
import 'appointments.dart';
import 'personal_care.dart';
import 'settings.dart';
import 'notes.dart';
import 'caretaker_add.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class IdentifyUserScreen extends StatefulWidget {
  final User user;

  IdentifyUserScreen({required this.user});

  @override
  _IdentifyUserScreenState createState() => _IdentifyUserScreenState();
}

class _IdentifyUserScreenState extends State<IdentifyUserScreen> {
  int unreadMessagesCount = 0;
  String? displayName;

  @override
  void initState() {
    super.initState();
    fetchUnreadMessagesCount();
  }

  void fetchUnreadMessagesCount() async {
    var userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.user.uid)
        .get();

    setState(() {
      unreadMessagesCount = userDoc.data()?['unreadMessagesCount'] ?? 0;
      displayName = userDoc.data()?['displayName'] ?? '';
    });
  }

  void _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LandingScreen()));
  }

  String extractFirstName(String email) {
    return email
        .split('@')
        .first
        .split('')
        .takeWhile((c) => RegExp(r'[a-zA-Z]').hasMatch(c))
        .join();
  }

  Future<List<Map<String, dynamic>>> fetchTodaysAppointments(
      String userId) async {
    CollectionReference appointments =
        FirebaseFirestore.instance.collection('Appointments');
    DateTime now = DateTime.now();
    DateTime startOfDay = DateTime(now.year, now.month, now.day);
    DateTime endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    DocumentSnapshot doc = await appointments.doc(userId).get();

    List<Map<String, dynamic>> todayEvents = [];
    if (doc.exists) {
      List<dynamic> events = doc['events'] ?? [];
      for (var event in events) {
        DateTime eventDate = (event['date'] as Timestamp).toDate();
        if (eventDate.isAfter(startOfDay) && eventDate.isBefore(endOfDay)) {
          todayEvents.add(event);
        }
      }
    }

    return todayEvents;
  }

  Future<List<Map<String, dynamic>>> fetchTodaysMedications(
      String userId) async {
    CollectionReference meds =
        FirebaseFirestore.instance.collection('medications');
    DocumentSnapshot doc = await meds.doc(userId).get();

    if (doc['medicationsList'] != null) {
      return List<Map<String, dynamic>>.from(doc['medicationsList']);
    } else {
      return [];
    }
  }

  Future<void> fetchUserProfile() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      var userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (userDoc.exists) {
        setState(() {
          displayName = userDoc.data()?['displayName'];
        });
      }
    }
  }

  Widget messagesButton(BuildContext context, FontSizeNotifier fontSizeNotifier,
      FontWeightNotifier fontWeightNotifier) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => CommunicationScreen()));
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text("Communication",
              style: TextStyle(
                  fontSize: fontSizeNotifier.fontSize,
                  fontWeight: fontWeightNotifier.fontWeight)),
          if (unreadMessagesCount > 0)
            Positioned(
              right: 10,
              top: 10,
              child: Container(
                padding: EdgeInsets.all(2),
                decoration: BoxDecoration(
                    color: Colors.red, borderRadius: BorderRadius.circular(6)),
                constraints: BoxConstraints(minWidth: 12, minHeight: 12),
                child: Text('$unreadMessagesCount',
                    style: TextStyle(color: Colors.white, fontSize: 8),
                    textAlign: TextAlign.center),
              ),
            ),
        ],
      ),
      style: ElevatedButton.styleFrom(
          minimumSize: Size(300, 60),
          backgroundColor: const Color.fromARGB(255, 30, 71, 104),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(30.0), // Adjust the radius as needed
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    fetchUserProfile();
    final fontSizeNotifier = Provider.of<FontSizeNotifier>(context);
    final fontWeightNotifier = Provider.of<FontWeightNotifier>(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color.fromARGB(255, 30, 71, 104),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _signOut(context),
          ),
          IconButton(
            icon: Icon(Icons.book),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NotesScreen(),
                ),
              );
            },
          ),
          Spacer(),
          IconButton(
            icon: Icon(Icons.manage_accounts),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CaretakerAddScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsPage(),
                ),
              );
            },
          ),
        ],
        title: Text(
          'EasyPeasyPal',
          style: TextStyle(
            fontSize: fontSizeNotifier.fontSize,
            fontFamily: 'Sacramento',
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(bottom: 16.0), // Add bottom padding here
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated Text
                Container(
                  height: 100, // Fixed height for the rotating text
                  child: DefaultTextStyle(
                    style: const TextStyle(
                      fontSize: 40.0,
                      fontFamily: 'Horizon',
                      color: Color(0xFF1E4768), // Text color
                    ),
                    child: AnimatedTextKit(
                      animatedTexts: [
                        RotateAnimatedText('EasyPeasyPal'),
                        RotateAnimatedText('Health'),
                        RotateAnimatedText('Wellness'),
                        RotateAnimatedText('All-In-One'),
                      ],
                      onTap: () {}, // No action on tap
                    ),
                  ),
                ),

                Image.asset(
                  'assets/logo.png',
                  height: 200,
                ),
                Text('Welcome',
                    style: TextStyle(
                        fontSize: fontSizeNotifier.fontSize * 1.5,
                        fontWeight: fontWeightNotifier.fontWeight)),
                Text(displayName ?? '',
                    style: TextStyle(
                        fontSize: fontSizeNotifier.fontSize * 1.2,
                        fontWeight: fontWeightNotifier.fontWeight)),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AppointmentsPage(),
                    ),
                  ),
                  child: Text("Appointments",
                      style: TextStyle(
                          fontSize: fontSizeNotifier.fontSize,
                          fontWeight: fontWeightNotifier.fontWeight)),
                  style: ElevatedButton.styleFrom(
                      minimumSize: Size(300, 60),
                      backgroundColor: const Color.fromARGB(255, 30, 71, 104),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            30.0), // Adjust the radius as needed
                      )),
                ),
                SizedBox(height: 10),
                messagesButton(context, fontSizeNotifier, fontWeightNotifier),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MedicationScreen(),
                    ),
                  ),
                  child: Text("Medication",
                      style: TextStyle(
                          fontSize: fontSizeNotifier.fontSize,
                          fontWeight: fontWeightNotifier.fontWeight)),
                  style: ElevatedButton.styleFrom(
                      minimumSize: Size(300, 60),
                      backgroundColor: const Color.fromARGB(255, 30, 71, 104),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            30.0), // Adjust the radius as needed
                      )),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PersonalCareScreen(),
                    ),
                  ),
                  child: Text("Personal Care",
                      style: TextStyle(
                          fontSize: fontSizeNotifier.fontSize,
                          fontWeight: fontWeightNotifier.fontWeight)),
                  style: ElevatedButton.styleFrom(
                      minimumSize: Size(300, 60),
                      backgroundColor: const Color.fromARGB(255, 30, 71, 104),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            30.0), // Adjust the radius as needed
                      )),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    List<Map<String, dynamic>> appointments =
                        await fetchTodaysAppointments(widget.user.uid); // retrieves appointment data from db for today
                    List<Map<String, dynamic>> medications =
                        await fetchTodaysMedications(widget.user.uid);  // retrieves medication data from db for today

                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Today's Events",
                              style: TextStyle(
                                  fontSize: fontSizeNotifier.fontSize,
                                  fontWeight: fontWeightNotifier.fontWeight)),
                          content: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Appointments:',
                                    style: TextStyle(
                                        fontWeight:
                                            fontWeightNotifier.fontWeight,
                                        fontSize: fontSizeNotifier.fontSize)),
                                ...appointments.map((event) => ListTile(
                                    title: Text(event['title'],
                                        style: TextStyle(
                                            fontSize: fontSizeNotifier.fontSize,
                                            fontWeight:
                                                fontWeightNotifier.fontWeight)),
                                    subtitle: Text(
                                        '${event['date'].toDate().hour}:${event['date'].toDate().minute}',
                                        style: TextStyle(
                                            fontSize: fontSizeNotifier.fontSize,
                                            fontWeight: fontWeightNotifier
                                                .fontWeight)))),
                                SizedBox(height: 20),
                                Text('Medications:',
                                    style: TextStyle(
                                        fontWeight:
                                            fontWeightNotifier.fontWeight,
                                        fontSize: fontSizeNotifier.fontSize)),
                                ...medications.map((med) => ListTile(
                                    title: Text(med['name'],
                                        style: TextStyle(
                                            fontSize: fontSizeNotifier.fontSize,
                                            fontWeight:
                                                fontWeightNotifier.fontWeight)),
                                    subtitle: Text(
                                        'Frequency: ${med['frequency']} times a day',
                                        style: TextStyle(
                                            fontSize: fontSizeNotifier.fontSize,
                                            fontWeight: fontWeightNotifier
                                                .fontWeight))))
                              ],
                            ),
                          ),
                          actions: [
                            TextButton(
                                child: Text('Close',
                                    style: TextStyle(
                                        fontSize: fontSizeNotifier.fontSize,
                                        fontWeight:
                                            fontWeightNotifier.fontWeight)),
                                onPressed: () => Navigator.of(context).pop())
                          ],
                        );
                      },
                    );
                  },
                  child: Text("Today's Events",
                      style: TextStyle(
                          fontSize: fontSizeNotifier.fontSize,
                          fontWeight: fontWeightNotifier.fontWeight)),
                  style: ElevatedButton.styleFrom(
                      minimumSize: Size(300, 60),
                      backgroundColor: const Color.fromARGB(255, 30, 71, 104),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            30.0), // Adjust the radius as needed
                      )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
