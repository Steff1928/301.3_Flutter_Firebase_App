import 'package:edubot/components/primary_button.dart';
import 'package:edubot/components/secondary_button.dart';
import 'package:edubot/services/authentication/login_or_register.dart';
import 'package:flutter/material.dart';

class IntroPage extends StatelessWidget {
  const IntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,

      // Background gradient
      body: Center(
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: <double>[0.25, 1],
              colors: <Color>[
                Theme.of(context).colorScheme.surface,
                Theme.of(context).colorScheme.inverseSurface
              ],
            ),
          ),

          // Main content
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height,
                maxWidth: MediaQuery.of(context).size.width,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Title
                  Padding(
                    padding: const EdgeInsets.only(top: 25),
                    child: Column(
                      children: [
                        SizedBox(height: 25), // Spacing

                        Text(
                          "EduBot",
                          style: TextStyle(
                            fontSize: 64,
                            color: Theme.of(context).colorScheme.primary,
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
                              color: Theme.of(context).colorScheme.secondary,
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
                              color: Theme.of(context).colorScheme.secondary,
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

                  SizedBox(height: 58),

                  // Login button
                  Padding(
                    padding: const EdgeInsets.only(bottom: 58.0),
                    child: Column(
                      children: [
                        PrimaryButton(
                          text: "Sign In",
                          height: 45,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        LoginOrRegister(showLoginPage: true),
                              ),
                            );
                          },
                        ),

                        SizedBox(height: 10),

                        // Register button
                        SecondaryButton(
                          text: "Create Account",
                          height: 45,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        LoginOrRegister(showLoginPage: false),
                              ),
                            );
                          },
                        ),

                        SizedBox(height: 25),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
