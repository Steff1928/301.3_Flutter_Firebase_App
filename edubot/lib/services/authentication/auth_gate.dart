import 'package:edubot/pages/chat_page.dart';
import 'package:edubot/pages/intro_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    // Listen to auth state changes
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // User is logged on
        if (snapshot.hasData) {
          return ChatPage();
        }
        // User is NOT logged in
        else {
          return IntroPage();
        }
      },
    );
  }
}
