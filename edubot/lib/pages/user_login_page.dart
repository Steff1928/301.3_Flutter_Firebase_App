import 'package:edubot/components/primary_button.dart';
import 'package:edubot/components/primary_text_field.dart';
import 'package:edubot/components/sso_tile.dart';
import 'package:edubot/services/authentication/auth_gate.dart';
import 'package:edubot/services/authentication/auth_manager.dart';
import 'package:flutter/material.dart';

class UserLoginPage extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final void Function()? onTap;

  UserLoginPage({super.key, required this.onTap});

  // Sign user in method
  void signUserIn(BuildContext context) async {
    // Get AuthManager and a context reference
    final AuthManager authManager = AuthManager();
    final navigator = Navigator.of(context);

    // Try login
    try {
      await authManager.signIn(_emailController.text, _passwordController.text);
    } catch (e) {
      print(e); // TODO: UI Element for unsuccessful login
    }

    if (authManager.getCurrentUser() != null) {
      navigator.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => AuthGate()),
          (route) => false,
        );
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
              "Sign In",
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

              // Forgot password
              Padding(
                padding: const EdgeInsets.only(right: 48, top: 10),
                child: Text(
                  "Forgot Password?",
                  style: TextStyle(
                    fontFamily: "Nunito",
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF05455B),
                  ),
                ),
              ),

              SizedBox(height: 35),

              // Login button
              Center(
                child: PrimaryButton(
                  text: "Login",
                  width: 318,
                  height: 45,
                  onPressed: () => signUserIn(context),
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
                    "Don't have an account? ",
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
                    //       builder: (context) => RegisterAccountPage(),
                    //     ),
                    //   );
                    // },
                    onTap: onTap,
                    child: Text(
                      "Sign Up",
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
