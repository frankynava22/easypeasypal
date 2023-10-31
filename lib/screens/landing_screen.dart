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
          // Store the user's details in Firestore
          final usersRef = FirebaseFirestore.instance.collection('users');
          final snapshot = await usersRef.doc(user.uid).get();

          // Check if user already exists, if not, add to Firestore
          if (!snapshot.exists) {
            usersRef.doc(user.uid).set({
              'uid': user.uid,
              'displayName': user.displayName,
              'photoURL': user.photoURL,
              'email': user.email,
              // Add any other necessary fields
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
          // Store the user's details in Firestore
          final usersRef = FirebaseFirestore.instance.collection('Susers');
          final snapshot = await usersRef.doc(suser.uid).get();

          // Check if user already exists, if not, add to Firestore
          if (!snapshot.exists) {
            usersRef.doc(suser.uid).set({
              'uid': suser.uid,
              'displayName': suser.displayName,
              'photoURL': suser.photoURL,
              'email': suser.email,
              // Add any other necessary fields
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
              style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold, color: Colors.blueGrey,),
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
              child: const Text("Login"),
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
            ),
            Spacer(flex: 1),
          ],
        ),
      ),
    );
  }
}
