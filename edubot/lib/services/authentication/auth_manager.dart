import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthManager {
  // instance of auth & firestore
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // sign up
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

        _firestore.collection("Users").doc(userCredential.user?.uid).set({
          'uid': user!.uid,
          'email': user.email,
          'fullName': user.displayName,
        });
        print("User registered with name: ${user.displayName}"); // TODO: UI for success message
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'Weak Password') {
        print('Password must be at least 8 characters long.'); // TODO: UI element for if the password is too short
      } else if (e.code == 'email-already-in-use') {
        print('An account already exists for this email.'); // TODO: UI element for if email already exists
      }
    }
  }

  // sign in
  Future<void> signIn(String email, String password) async {
    try {
      // Sign user in
      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email, password: password);

      // Save user info if it doesn't already exist
      _firestore.collection("Users").doc(userCredential.user?.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
        'fullName': userCredential.user!.displayName,
      });
      print("Successful login for ${userCredential.user?.displayName}");
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.'); // TODO: UI element if email doesn't exist
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.'); // TODO: UI element if password is invalid
      }
    }
  }

  // sign out
}
