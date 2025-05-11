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
  Future<void> createAccount(String email, String password, String fullName) async {
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
          'name': user.displayName,
        });
        print("User registered with name: ${user.displayName}",); // TODO: UI for success message
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw Exception('Password must be at least 6 characters long.');
      } else if (e.code == 'email-already-in-use') {
        throw Exception('An account already exists for this email.');
      } else if (e.code == 'invalid-email') {
        throw Exception('Invalid email.');
      }
      else {
        throw Exception("Authentication Error: ${e.code}");
      }

    } 
  }

  // sign in
  Future<UserCredential> signIn(String email, String password) async {
    try {
      // Sign user in
      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email, password: password);

      // Save user info if it doesn't already exist
      _firestore.collection("Users").doc(userCredential.user?.uid).set(
        {
        'uid': userCredential.user!.uid,
        'email': email,
        'name': userCredential.user!.displayName,
        },
      );
      
      print("Successful login for ${userCredential.user?.displayName}"); // TODO: Snackbar to notify users of successful login
      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-credential') {
        throw Exception('Invalid email or password.');
      } else if (e.code == 'invalid-email') {
        throw Exception('Invalid Email.');
      }
      else {
        throw Exception('Authentication Error: ${e.code} ');
      }
      
    }
  }

  // sign out
  Future<void> signOut() async {
    return await _auth.signOut();
  }
}
