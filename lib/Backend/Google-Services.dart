import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pos/Screen/DashBoard/dashboard.dart';
import 'package:pos/Screen/DashBoard/login-page.dart';

class GoogleServicesClass {
  Future<void> googlesignin(BuildContext context) async {
    // Capture navigator before async gap
    final navigator = Navigator.of(context);

    try {
      final GoogleSignInAccount? guser = await GoogleSignIn().signIn();
      // User cancelled the sign-in flow
      if (guser == null) return;

      final GoogleSignInAuthentication gauth = await guser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: gauth.accessToken,
        idToken: gauth.idToken,
      );

      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        navigator.pushReplacement(
          MaterialPageRoute(
            builder: (context) => MyDashboard(user1: user),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      Fluttertoast.showToast(
          msg: 'Google sign-in failed: ${e.message ?? e.code}');
    } catch (e) {
      Fluttertoast.showToast(msg: 'Google sign-in failed. Please try again.');
    }
  }

  Future<void> googlesignout(BuildContext context) async {
    final navigator = Navigator.of(context);
    try {
      await GoogleSignIn().signOut();
      await FirebaseAuth.instance.signOut();
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const loginPage()),
        (route) => false,
      );
    } catch (e) {
      Fluttertoast.showToast(msg: 'Sign-out failed. Please try again.');
    }
  }
}
