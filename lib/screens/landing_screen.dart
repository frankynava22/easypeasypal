import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:chatbot/screens/identify_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chatbot/screens/caretaker_start.dart';

class LandingScreen extends StatefulWidget {
  @override
  _LandingScreenState createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> _handleSignIn() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        final UserCredential authResult =
            await _auth.signInWithCredential(credential);
        final User? user = authResult.user;

        if (user != null) {
          // Check if the user belongs to 'Susers' collection
          final usersRef = FirebaseFirestore.instance.collection('Susers');
          final snapshot = await usersRef.doc(user.uid).get();

          if (snapshot.exists) {
            // User belongs to 'Susers' collection, show snackbar error
            showSnackbarError("Logged in as Caretaker, please use Caretaker Access");
            return null;
          }

          // Store the user's details in Firestore
          final usersCollectionRef =
              FirebaseFirestore.instance.collection('users');
          final userSnapshot = await usersCollectionRef.doc(user.uid).get();

          // Check if user already exists, if not, add to Firestore
          if (!userSnapshot.exists) {
            usersCollectionRef.doc(user.uid).set({
              'uid': user.uid,
              'displayName': user.displayName,
              'photoURL': user.photoURL,
              'email': user.email,
              
            });
          }
        }

        return user;
      }
    } catch (error) {
      print(error);
    }
    return null;
  }

  Future<User?> _superHandleSignIn() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        final UserCredential authResult =
            await _auth.signInWithCredential(credential);
        final User? suser = authResult.user;

        if (suser != null) {
          // Check if the user already exists in 'users' collection
          final usersCollectionRef =
              FirebaseFirestore.instance.collection('users');
          final userSnapshot = await usersCollectionRef.doc(suser.uid).get();

          if (userSnapshot.exists) {
            // User already exists in 'users' collection, show snackbar error
            showSnackbarError("Logged in as User, please use Login");
            return null;
          }

          // Store the user's details in Firestore for 'Susers' collection
          final susersRef = FirebaseFirestore.instance.collection('Susers');
          final snapshot = await susersRef.doc(suser.uid).get();

          // Check if user already exists, if not, add to Firestore
          if (!snapshot.exists) {
            susersRef.doc(suser.uid).set({
              'uid': suser.uid,
              'displayName': suser.displayName,
              'photoURL': suser.photoURL,
              'email': suser.email,
              
            });
          }
        }

        return suser;
      }
    } catch (error) {
      print(error);
    }
    return null;
  }

  void showSnackbarError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Spacer(flex: 6),
            const Text(
              "Welcome to ",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            Text(
              "EasyPeasyPal",
              style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold, color: const Color.fromARGB(255, 30, 71, 104),),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final User? user = await _handleSignIn();
                if (user != null) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => IdentifyUserScreen(user: user),
                    ),
                  );
                } else {
                  // Handle sign-in error or cancellation.
                }
              },
              child: const Text("Create Account"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 30, 71, 104), // Change the background color to blue
              ),
            ),
            SizedBox(height: 10),
            TextButton(
              onPressed: () async {
                final User? user = await _handleSignIn();
                if (user != null) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => IdentifyUserScreen(user: user),
                    ),
                  );
                } else {
                  // Handle login error or cancellation.
                }
              },
              child: Text(
                "Login",
                style: TextStyle(
                  fontSize: 22, // Change the font size to 18
                  color: const Color.fromARGB(255, 30, 71, 104), // Change the text color to red
                ),
              ),
            ),
            Spacer(flex: 5),
            ElevatedButton(
              onPressed: () async {
                final User? user = await _superHandleSignIn();
                if (user != null) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CaretakerStartScreen(user: user),
                    ),
                  );
                } else {
                  // Handle sign-in error or cancellation.
                }
              },
              child: const Text("CareTaker Access"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 30, 71, 104), 
              ),
            ),

            Spacer(flex: 1),
          ],
        ),
      ),
    );
  }
}
