import 'package:edubot/components/primary_button.dart';
import 'package:edubot/components/secondary_button.dart';
import 'package:edubot/services/authentication/login_or_register.dart';
import 'package:flutter/material.dart';

class IntroPage extends StatelessWidget {
  const IntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        // Background gradient
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: <double>[0.25, 1],
              colors: <Color>[Color(0xFFFAFAFA), Color(0xFF96C0CA)],
            ),
          ),
          // Main content
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Title
              Padding(
                padding: const EdgeInsets.only(top: 25),
                child: Column(
                  children: [
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

                    SizedBox(height: 7), // Spacing
                    // Subtitle #1
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: Text(
                        "Welcome to Edubot - The Educational Chatbot for Classrooms.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF364B55),
                          fontFamily: "Nunito",
                          letterSpacing: 0.32,
                        ),
                      ),
                    ),

                    SizedBox(height: 7), // Spacing
                    // Subtitle #2
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: Text(
                        "Sign in or create an account to get started.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF364B55),
                          fontFamily: "Nunito",
                          letterSpacing: 0.32,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Image
              Padding(
                padding: const EdgeInsets.only(top: 17),
                child: Image.asset(
                  'lib/assets/images/intro-image.png',
                  height: 207,
                ),
              ),

              SizedBox(height: 58), // Spacing
              // Sign In/Register Buttons
              Column(
                children: [
                  PrimaryButton(
                    text: "Sign In",
                    width: 318,
                    height: 45,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoginOrRegister(showLoginPage: true,),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 10),
                  SecondaryButton(
                    text: "Create Account",
                    width: 318,
                    height: 45,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoginOrRegister(showLoginPage: false,),
                        ),
                      );
                    },
                  ),
                ],
              ),

              SizedBox(height: 58), // Spacing
            ],
          ),
        ),
      ),
    );
  }
}
