import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import './identify_user.dart';

class LandingScreen extends StatelessWidget {
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
        return user;
      }
    } catch (error) {
      print(error);
    }
    return null; // Ensure null is returned if the user did not sign in or there was an exception
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              "Welcome to Chatbot",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final User? user = await _handleSignIn();
                if (user != null) {
                  // User successfully signed in with Google.
                  // Navigate to next screen or handle accordingly.
                } else {
                  // Error or user cancelled the sign-in process.
                }
              },
              child: const Text("Create Account"),
            ),
            SizedBox(height: 10),
            TextButton(
              onPressed: () async {
                // You can use the same _handleSignIn method for login too.
                // Google Sign-In will recognize if the user has already
                // authenticated with Google before.
                final User? user = await _handleSignIn();
                if (user != null) {
                  // User successfully logged in with Google.
                  // Navigate to next screen or handle accordingly.
                } else {
                  // Error or user cancelled the login process.
                }
              },
              child: const Text("Login"),
            ),
          ],
        ),
      ),
    );
  }
}
