import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleService {
  // Get Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Google sign in
  Future<void> signInWithGoogle() async {
    // Sign in with credential

    final GoogleSignIn googleSignIn = GoogleSignIn();
    try {
      // Begin interactive sign in process
      final GoogleSignInAccount? gUser = await googleSignIn.signIn();

      if (gUser == null) {
        // User closed the pop-up or cancelled sign in
        print('Sign in cancelled by user');
      } else {
        // Obtain auth details from request
        final GoogleSignInAuthentication gAuth = await gUser.authentication;

        // Create new user credential
        final credential = GoogleAuthProvider.credential(
          idToken: gAuth.idToken,
          accessToken: gAuth.accessToken,
        );

        final userCredential = await FirebaseAuth.instance.signInWithCredential(
          credential,
        );

        // Save details to Firestore database
        _firestore.collection("Users").doc(userCredential.user?.uid).set({
          'uid': userCredential.user!.uid,
          'email': userCredential.user!.email,
          'fullName': userCredential.user!.displayName,
        });
      }
    } catch (e) {
      print('Authentication Error $e');
    }
  }
}
