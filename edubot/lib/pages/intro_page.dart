import 'package:flutter/material.dart';

class IntroPage extends StatelessWidget {
  const IntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[Color(0xFFFAFAFA), Color(0xFF96C0CA)],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Title
              Text(
                "EduBot",
                style: TextStyle(
                  fontSize: 64,
                  color: Color(0xFF074F67),
                  fontFamily: "Cabin",
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.28,
                ),
              ),

              SizedBox(height: 7),

              // Subtitle #1
              Text(
                "Welcome to Edubot - The Educational Chatbot for Classrooms.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF364B55),
                  fontFamily: "Nunito",
                  letterSpacing: 0.32,
                ),
              ),

              SizedBox(height: 7),

              // Subtitle #2
              Text(
                "Sign in or create an account to get started.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF364B55),
                  fontFamily: "Nunito",
                  letterSpacing: 0.32,
                ),
              ),

              // Image
              // Image.asset('lib/assets/images/intro-image.png', height: 207,)

              // Sign In Btn

              // Register Btn
            ],
          ),
        ),
      ),
    );
  }
}
