import 'package:edubot/components/primary_button.dart';
import 'package:edubot/components/primary_text_field.dart';
import 'package:edubot/components/sso_tile.dart';
import 'package:edubot/services/authentication/auth_gate.dart';
import 'package:edubot/services/authentication/auth_manager.dart';
import 'package:flutter/material.dart';

class RegisterAccountPage extends StatelessWidget {
  RegisterAccountPage({super.key, required this.onTap});
  // Text controllers for the text fields
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();

  final void Function()? onTap;

  // Create new user account method
  void registerNewUser(BuildContext context) async {
    // Get auth manager
    final AuthManager authManager = AuthManager();

    // Get the context reference
    final navigator = Navigator.of(context);

    // Show loading circle
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return Center(child: CircularProgressIndicator(color: Colors.blue));
      },
    );

    if (_confirmPassController.text == _passwordController.text) {
      try {
        await authManager.createAccount(
          _emailController.text,
          _passwordController.text,
          _fullNameController.text,
        );
      } catch (e) {
        print(e);
        navigator.pop();
      }
      if (authManager.getCurrentUser() != null) {
        navigator.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => AuthGate()),
          (route) => false,
        );
      }
    }
    // Throw an error if passwords don't match
    else {
      print("Confirm password doesn't match password"); // TODO: UI element for confirm password error
      navigator.pop();
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
                controller: _fullNameController,
              ),

              SizedBox(height: 25),

              // Email
              PrimaryTextField(
                label: "Email",
                obscureText: false,
                controller: _emailController,
              ),

              SizedBox(height: 25),

              // Password
              PrimaryTextField(
                label: "Password",
                obscureText: true,
                controller: _passwordController,
              ),

              SizedBox(height: 25),

              // Confirm password
              PrimaryTextField(
                label: "Confirm Password",
                obscureText: true,
                controller: _confirmPassController,
              ),

              SizedBox(height: 35),

              // Register button
              Center(
                child: PrimaryButton(
                  text: "Sign Up",
                  width: 318,
                  height: 45,
                  onPressed: () => registerNewUser(context),
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
                    // onTap: () {
                    //   Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //       builder: (context) => UserLoginPage(),
                    //     ),
                    //   );
                    // },
                    onTap: onTap,
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
