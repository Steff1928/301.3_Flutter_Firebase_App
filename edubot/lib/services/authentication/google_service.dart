import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleService {
  // Get Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Google sign in
  signInWithGoogle() async {
    // Begin interactive sign in process
    final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();

    // Obtain auth details from request
    final GoogleSignInAuthentication gAuth = await gUser!.authentication;

    // Create new user credential
    final credential = GoogleAuthProvider.credential(
      idToken: gAuth.idToken,
      accessToken: gAuth.accessToken,
    );

    // Sign in with credential
    final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

    // Save details to Firestore database
    _firestore.collection("Users").doc(userCredential.user?.uid).set({
          'uid': userCredential.user!.uid,
          'email': userCredential.user!.email,
          'fullName': userCredential.user!.displayName,
        });

    // Return userCredential
    return userCredential;
  }
}