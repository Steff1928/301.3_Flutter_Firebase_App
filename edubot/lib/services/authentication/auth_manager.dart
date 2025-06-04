import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthManager {
  // Get instance of auth & firestore
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user method
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Update email method
  Future<void> updateEmail(String newEmail) async {
    User? user = getCurrentUser();
    if (user != null) {
      try {
        // Update email
        await user.verifyBeforeUpdateEmail(newEmail);

        // Reload user to get updated info and reference it
        await user.reload();
        user = getCurrentUser();

        // Save user info to Firestore
        _firestore.collection('Users').doc(user?.uid).update({
          'email': user?.email,
        });
      } on FirebaseAuthException catch (e) {
        // Handle errors
        if (e.code == 'unknown') {
          throw Exception("Unknown email");
        } else if (e.code == 'invalid-new-email') {
          throw Exception("Invalid new email");
        }
        else if (e.code == 'requires-recent-login') {
          throw Exception("Requires recent login");
        } else {
          throw Exception("Error updating email: ${e.code}");
        }
      }
    } else {
      throw Exception("No user is currently signed in.");
    }
  }

  // Update display name method
  Future<void> updateDisplayName(String newDisplayName) async {
    User? user = getCurrentUser();
    if (user != null) {
      try {
        // Update display name
        await user.updateDisplayName(newDisplayName);

        // Reload user to get updated info and reference it
        await user.reload();
        user = getCurrentUser();

        // Save user info to Firestore
        _firestore.collection('Users').doc(user?.uid).update({
          'name': user?.displayName,
        });
      } on FirebaseAuthException catch (e) {
        // Handle errors
        throw Exception("Error updating display name: ${e.code}");
      }
    } else {
      throw Exception("No user is currently signed in.");
    }
  }

  // Reset password method
  Future<void> resetPassword(String email) async {
    try {
      // Send user reset email
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      // Handle errors
      if (e.code == 'invalid-email') {
        throw Exception("Invalid Email");
      } else {
        throw Exception("Error: ${e.code}");
      }
    }
  }

  // Sign up method
  Future<void> createAccount(
    String email,
    String password,
    String fullName,
  ) async {
    try {
      // Register new user
      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      User? user = userCredential.user;

      if (user != null) {
        // Update display name
        await user.updateDisplayName(fullName);

        // Reload and fetch user data
        await user.reload();

        // Get the updated user
        user = getCurrentUser();

        // Save user info to Firestore
        _firestore.collection('Users').doc(userCredential.user?.uid).set({
          'uid': user!.uid,
          'email': user.email,
          'name': user.displayName,
        });
      }
    } on FirebaseAuthException catch (e) {
      // Handle errors
      if (e.code == 'weak-password') {
        throw Exception('Password must be at least 6 characters long.');
      } else if (e.code == 'email-already-in-use') {
        throw Exception('An account already exists for this email.');
      } else if (e.code == 'invalid-email') {
        throw Exception('Invalid email.');
      } else {
        throw Exception("Authentication Error: ${e.code}");
      }
    }
  }

  // Sign in method
  Future<UserCredential> signIn(String email, String password) async {
    try {
      // Try sign user in
      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email, password: password);

      // Save user info if it doesn't already exist
      _firestore.collection("Users").doc(userCredential.user?.uid).update({
        'uid': userCredential.user!.uid,
        'email': email,
        'name': userCredential.user!.displayName,
      });

      return userCredential;
    } on FirebaseAuthException catch (e) {
      // Handle errors
      if (e.code == 'invalid-credential') {
        throw Exception('Invalid email or password.');
      } else if (e.code == 'invalid-email') {
        throw Exception('Invalid Email.');
      } else {
        throw Exception('Authentication Error: ${e.code} ');
      }
    }
  }

  // Sign out method
  Future<void> signOut() async {
    return await _auth.signOut(); // Sign out user
  }
}
