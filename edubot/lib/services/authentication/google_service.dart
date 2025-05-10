import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleService {
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

    // Save details to database
    _firestore.collection("Users").doc(gUser.id).set({
          'uid': gUser.id,
          'email': gUser.email,
          'fullName': gUser.displayName,
        });

    // Return userCredential
    return userCredential;
  }
}