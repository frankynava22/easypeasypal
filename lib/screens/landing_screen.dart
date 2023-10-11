import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:chatbot/FSDB/user_model.dart';
import 'package:chatbot/FSDB/user_repository.dart';
import 'package:chatbot/screens/identify_user.dart';
import 'package:get/get.dart';

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
          final fullName = user.displayName ?? "";
          final email = user.email ?? "";

          // Save user data to Firestore
          Get.lazyPut(()=>UserRepository.instance.createUser(UserModel(email: email, fullName: fullName)));

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => IdentifyUserScreen(user: user),
            ),
          );
        } else {
          // Handle sign-in error or cancellation.
        }
      }
    } catch (error) {
      print(error);
      // Handle sign-in error.
    }
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
              onPressed: _handleSignIn,
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
          ],
        ),
      ),
    );
  }
}

