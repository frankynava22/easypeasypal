import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:chatbot/screens/identify_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chatbot/screens/caretaker_start.dart';
import 'package:animations/animations.dart';

class LandingScreen extends StatefulWidget {
  @override
  _LandingScreenState createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> _handleSignIn() async { // sign in for client access
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,  // token granted for legitimate access 
          idToken: googleAuth.idToken,
        );
        final UserCredential authResult =
            await _auth.signInWithCredential(credential);
        final User? user = authResult.user;

        if (user != null) {

          
          final usersCollectionRef = FirebaseFirestore.instance.collection('users'); //firestore reference
          final userSnapshot = await usersCollectionRef.doc(user.uid).get();

          // Check if user already exists, if not, add to Firestore
          if (!userSnapshot.exists) {
            usersCollectionRef.doc(user.uid).set({ // Store the user's details in Firestore
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

  Future<User?> _superHandleSignIn() async { // signin for caretaker access
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,  // token granted for legitimate access 
          idToken: googleAuth.idToken,
        );
        final UserCredential authResult =
            await _auth.signInWithCredential(credential);
        final User? suser = authResult.user;

        if (suser != null) {
        
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

  void showSnackbarError(String message) { // snackbar error function
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _navigateToScreen(Widget screen) {
    Navigator.of(context).push(PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => screen,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeThroughTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          child: child,
        );
      },
    ));
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
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            Image.asset('assets/logo.png', height: 100), // Logo added here
            Text(
              "EasyPeasyPal",
              style: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 30, 71, 104)),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final User? user = await _handleSignIn();
                if (user != null) {
                  _navigateToScreen(IdentifyUserScreen(user: user));
                } else {
                  // Handle sign-in error or cancellation.
                }
              },
              child: const Text("Create Account"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 30, 71, 104),
              ),
            ),
            SizedBox(height: 10),
            TextButton(
              onPressed: () async {
                final User? user = await _handleSignIn();
                if (user != null) {
                  _navigateToScreen(IdentifyUserScreen(user: user));
                } else {
                  // Handle login error or cancellation.
                }
              },
              child: Text(
                "Login",
                style: TextStyle(
                    fontSize: 22, color: Color.fromARGB(255, 30, 71, 104)),
              ),
            ),
            Spacer(flex: 5),
            ElevatedButton(
              onPressed: () async {
                final User? user = await _superHandleSignIn();
                if (user != null) {
                  _navigateToScreen(CaretakerStartScreen(user: user));
                } else {
                  // Handle sign-in error or cancellation.
                }
              },
              child: const Text("CareTaker Access"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 30, 71, 104),
              ),
            ),
            Spacer(flex: 1),
          ],
        ),
      ),
    );
  }
}
