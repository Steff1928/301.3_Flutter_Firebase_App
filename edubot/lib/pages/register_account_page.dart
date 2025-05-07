import 'package:edubot/components/primary_button.dart';
import 'package:edubot/components/primary_text_field.dart';
import 'package:edubot/components/sso_tile.dart';
import 'package:edubot/pages/user_login_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterAccountPage extends StatefulWidget {

  const RegisterAccountPage({super.key});

  @override
  State<RegisterAccountPage> createState() => _RegisterAccountPageState();
}

class _RegisterAccountPageState extends State<RegisterAccountPage> {
  final TextEditingController _fullName = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();

  // Create new user account method
  void registerNewUser() async {
    try {
      // Create user account if confirm password matches password
      // THE FOLLOWING CODE IS ALL TEST CODE AND WILL BE CHANGED
      if (_confirmPassword.text == _password.text) {
        final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _email.text,
            password: _password.text,
          );
          await credential.user?.updateDisplayName(_fullName.text); // Update display name with full name
          print("Account created successfully");
      } else {
        print("Confirm password does not much password");
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') { // Don't accept weak passwords
        print('The password is too weak.');
      } else if (e.code == 'email-already-in-use') { // Don't accept duplicate emails
        print('The account already exists for that email');
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFAFAFA),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Heading
          Padding(
            padding: const EdgeInsets.only(left: 48, top: 133),
            child: Text(
              "Register",
              style: TextStyle(
                fontFamily: "Cabin",
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Color(0xFF074F67),
              ),
            ),
          ),

          SizedBox(height: 45),

          // Text fields
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Full name
              PrimaryTextField(
                label: "Full Name",
                obscureText: false,
                controller: _fullName,
              ),

              SizedBox(height: 25),

              // Email
              PrimaryTextField(
                label: "Email",
                obscureText: false,
                controller: _email,
              ),

              SizedBox(height: 25),

              // Password
              PrimaryTextField(
                label: "Password",
                obscureText: true,
                controller: _password,
              ),

              SizedBox(height: 25),

              // Confirm password
              PrimaryTextField(
                label: "Confirm Password",
                obscureText: true,
                controller: _confirmPassword,
              ),

              SizedBox(height: 35),

              // Register button
              Center(
                child: PrimaryButton(
                  text: "Sign Up",
                  width: 318,
                  height: 45,
                  onPressed: registerNewUser,
                ),
              ),
            ],
          ),

          SizedBox(height: 50),

          Center(
            child: Text(
              "OR",
              style: TextStyle(
                fontFamily: "Nunito",
                fontSize: 16,
                color: Color(0xFF364B55),
              ),
            ),
          ),

          SizedBox(height: 50),

          // Sign in with Google
          Column(
            children: [
              SsoTile(
                imagePath: "lib/assets/images/google.png",
                width: 318,
                height: 52,
              ),
              SizedBox(height: 15),
              // Register Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account? ",
                    style: TextStyle(
                      fontFamily: "Nunito",
                      fontSize: 16,
                      color: Color(0xFF364B55),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserLoginPage(),
                        ),
                      );
                    },
                    child: Text(
                      "Sign In",
                      style: TextStyle(
                        fontFamily: "Nunito",
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF05455B),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
