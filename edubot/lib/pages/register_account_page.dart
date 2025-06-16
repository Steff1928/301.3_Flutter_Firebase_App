import 'package:edubot/components/custom_snack_bar.dart';
import 'package:edubot/components/error_tile.dart';
import 'package:edubot/components/primary_button.dart';
import 'package:edubot/components/primary_text_field.dart';
import 'package:edubot/components/sso_tile.dart';
import 'package:edubot/services/authentication/auth_gate.dart';
import 'package:edubot/services/authentication/auth_manager.dart';
import 'package:edubot/services/authentication/google_service.dart';
import 'package:flutter/material.dart';

class RegisterAccountPage extends StatefulWidget {
  const RegisterAccountPage({super.key, required this.onTap});
  final void Function()? onTap; // Callback function to switch to login page

  @override
  State<RegisterAccountPage> createState() => _RegisterAccountPageState();
}

class _RegisterAccountPageState extends State<RegisterAccountPage> {
  // Text controllers for the text fields
  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();
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
        Icon(Icons.error, color: Colors.red),
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

  // Create new user account method
  void registerNewUser(BuildContext context) async {
    // Get auth manager
    final AuthManager authManager = AuthManager();

    // Get the context reference
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

    // Assign controller values to local variables
      final String displayName = _displayNameController.text.trim();
      final String email = _emailController.text.trim();
      final String password = _passwordController.text.trim();
      final String confirmPass = _confirmPassController.text.trim();

    // Check if confirm pass matches pass
    if (confirmPass == password) {
      // Check if all fields are filled
      final areFieldsFilled = displayName.isNotEmpty &&
          email.isNotEmpty &&
          password.isNotEmpty &&
          confirmPass.isNotEmpty;

      // Check to see if all fields are filled, if so, attempt to create an account
      if (areFieldsFilled) {
        try {
          await authManager.createAccount(
            email,
            password,
            displayName,
          );
          // Show snackbar if account creation is successful
          showSnackbar(
            scaffoldMessenger,
            "Account created successfully",
            Icon(Icons.check_circle, color: Colors.green),
            true,
          );
        } catch (e) {
          // Set the value of "_errorMessage" (removing "Exception: " prefix)
          setState(() {
            _errorMessage =
                e is Exception
                    ? e.toString().replaceFirst('Exception: ', '')
                    : e.toString();
          });
          navigator.pop();
        }
        if (authManager.getCurrentUser() != null) {
          navigator.pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => AuthGate()),
            (route) => false,
          );
        }
      } else {
        setState(() {
          _errorMessage = "All fields are required.";
        });
        navigator.pop();
        return;
      }
    }
    // Throw an error if passwords don't match
    else {
      if (confirmPass.isNotEmpty && password.isNotEmpty) {
        setState(() {
          _errorMessage = "Confirm password doesn't match password.";
        });
      } else {
        setState(() {
          _errorMessage = "All fields are required.";
        });
      }

      navigator.pop();
    }
  }

  @override
  void dispose() {
    // Dispose of the text controllers to free up resources
    _displayNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Page style
      backgroundColor: Theme.of(context).colorScheme.surface,
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
                    "Register",
                    style: TextStyle(
                      fontFamily: "Cabin",
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),

                // Display error message if it exists
                if (_errorMessage != null)
                  ErrorTile(errorMessage: _errorMessage.toString()),

                SizedBox(height: 25),

                // Text fields
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Display name
                    PrimaryTextField(
                      label: "Display Name",
                      obscureText: false,
                      controller: _displayNameController,
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
                        height: 45,
                        onPressed: () => registerNewUser(context),
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

                // Sign in with Google
                Padding(
                  padding: const EdgeInsets.only(bottom: 50.0),
                  child: Column(
                    children: [
                      SsoTile(
                        onPressed: signInWithGoogle,
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
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                          GestureDetector(
                            onTap: widget.onTap,
                            child: Text(
                              "Sign In",
                              style: TextStyle(
                                fontFamily: "Nunito",
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                          ),
                        ],
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
