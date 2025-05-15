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
