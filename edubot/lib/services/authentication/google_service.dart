import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edubot/services/firebase/firebase_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

class GoogleService {
  // Get Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Google sign in
  Future<void> signInWithGoogle(BuildContext context) async {
    final firebaseProvider = Provider.of<FirebaseProvider>(context, listen: false);

    // Sign in with credential
    final GoogleSignIn googleSignIn = GoogleSignIn();

    try {
      // Try begin interactive sign in process
      final GoogleSignInAccount? gUser = await googleSignIn.signIn();

      if (gUser == null) {
        // User closed the pop-up or cancelled sign in
        return;
      } else {
        // Obtain auth details from request
        final GoogleSignInAuthentication gAuth = await gUser.authentication;

        // Create new user credential
        final credential = GoogleAuthProvider.credential(
          idToken: gAuth.idToken,
          accessToken: gAuth.accessToken,
        );

        // Sign in to Firebase with credential
        final userCredential = await FirebaseAuth.instance.signInWithCredential(
          credential,
        );

        // Set details within Firestore database (prevent 'activeConversationId' getting overridden if it doesn't exist)
        String? conversationId = await firebaseProvider.getSavedConversationId();

        _firestore.collection("Users").doc(userCredential.user?.uid).set({
          'uid': userCredential.user!.uid,
          'email': userCredential.user!.email,
          'name': userCredential.user!.displayName,
          'activeConversationId': conversationId,
        });
      }
    } catch (e) {
      // Handle errors silently
      return;
    }
  }
}
