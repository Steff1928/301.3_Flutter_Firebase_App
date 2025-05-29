import 'package:edubot/components/error_tile.dart';
import 'package:edubot/components/primary_button.dart';
import 'package:edubot/components/primary_text_field.dart';
import 'package:edubot/components/sso_tile.dart';
import 'package:edubot/components/custom_snack_bar.dart';
import 'package:edubot/pages/password_recovery_page.dart';
import 'package:edubot/services/authentication/auth_gate.dart';
import 'package:edubot/services/authentication/auth_manager.dart';
import 'package:edubot/services/authentication/google_service.dart';
import 'package:flutter/material.dart';

class UserLoginPage extends StatefulWidget {
  final void Function()? onTap; // Function to navigate to the sign up page

  const UserLoginPage({super.key, required this.onTap});

  @override
  State<UserLoginPage> createState() => _UserLoginPageState();
}

class _UserLoginPageState extends State<UserLoginPage> {
  // Text controllers for the text fields
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // String to store error messages
  String? _errorMessage;

  // Sign user in with Google method
  void signInWithGoogle() async {
    // Get required services
    final GoogleService googleService = GoogleService();
    final AuthManager authManager = AuthManager();

    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    // Clear previous errors
    setState(() {
      _errorMessage = null;
    });

    // Show loading circle
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return Center(child: CircularProgressIndicator(color: Colors.blue));
      },
    );

    // Attempt google sign in
    await googleService.signInWithGoogle(context);

    // Check if user is signed in (all messages displayed in the snackbar)
    if (authManager.getCurrentUser() != null) {
      showSnackbar(
        scaffoldMessenger,
        "Login with Google successful",
        Icon(Icons.check_circle, color: Colors.green),
        true,
      );
    } else {
      // Show error notification if Google sign in fails
      showSnackbar(
        scaffoldMessenger,
        "Error signing in with Google",
        Icon(Icons.error, color: Colors.red,),
        false,
      );
    }

    // Dismiss loading circle after user is finished with pop up (either closing it or signing in)
    navigator.pop();

    // Remove all pages in the navigation stack
    if (authManager.getCurrentUser() != null) {
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => AuthGate()),
        (route) => false,
      );
    }
  }

  // Sign user in with email and password method
  void signInWithEmailAndPassword(BuildContext context) async {
    // Get AuthManager instance
    final AuthManager authManager = AuthManager();
    final navigator = Navigator.of(context);

    final scaffoldMessenger = ScaffoldMessenger.of(context);

    // Clear previous errors
    setState(() {
      _errorMessage = null;
    });

    // Show loading circle
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return Center(child: CircularProgressIndicator(color: Colors.blue));
      },
    );

    // If all fields are filled, try login
    if (_emailController.text != "" && _passwordController.text != "") {
      try {
        await authManager.signIn(
          _emailController.text,
          _passwordController.text,
        );
        showSnackbar(
          scaffoldMessenger,
          "Login successful",
          Icon(Icons.check_circle, color: Colors.green),
          true,
        );
      } catch (e) {
        navigator.pop();
        // Set the value of _errorMessage (removing "Exception: " prefix)
        setState(() {
          _errorMessage =
              e is Exception
                  ? e.toString().replaceFirst('Exception: ', '')
                  : e.toString();
        });
      }
    } else {
      // Show error message if any field is empty
      setState(() {
        _errorMessage = "All fields are required.";
      });
      navigator.pop();
      return;
    }

    // Remove all pages in the navigation stack
    if (authManager.getCurrentUser() != null) {
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => AuthGate()),
        (route) => false,
      );
    }
  }

  @override
  void dispose() {
    // Dispose of the text controllers to free up resources
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      // Allow a scrollable widget
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 500),
            child: Column(
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
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),

                // Display error message
                if (_errorMessage != null)
                  ErrorTile(errorMessage: _errorMessage.toString()),

                SizedBox(height: 25),

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
                      child: GestureDetector(
                        // Navigate to password recovery page
                        onTap:
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PasswordRecoveryPage(),
                              ),
                            ),
                        child: Text(
                          "Forgot Password?",
                          style: TextStyle(
                            fontFamily: "Nunito",
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 35),

                    // Login button
                    Center(
                      child: PrimaryButton(
                        text: "Login",
                        height: 45,
                        onPressed: () => signInWithEmailAndPassword(context),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 44),

                Center(
                  child: Text(
                    "OR",
                    style: TextStyle(
                      fontFamily: "Nunito",
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),

                SizedBox(height: 44),

                // Google sign in button
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Column(
                    children: [
                      SsoTile(
                        onPressed: signInWithGoogle,
                        imagePath: "lib/assets/images/google.png",
                        width: 318,
                        height: 52,
                      ),

                      // Register Link
                      SizedBox(height: 15),

                      Padding(
                        padding: const EdgeInsets.only(bottom: 50.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account? ",
                              style: TextStyle(
                                fontFamily: "Nunito",
                                fontSize: 16,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                            GestureDetector(
                              onTap: widget.onTap,
                              child: Text(
                                "Sign Up",
                                style: TextStyle(
                                  fontFamily: "Nunito",
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
