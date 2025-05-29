import 'package:edubot/components/custom_snack_bar.dart';
import 'package:edubot/components/primary_button.dart';
import 'package:edubot/components/primary_text_field.dart';
import 'package:edubot/services/authentication/auth_manager.dart';
import 'package:flutter/material.dart';

class PasswordRecoveryPage extends StatefulWidget {
  const PasswordRecoveryPage({super.key});

  @override
  State<PasswordRecoveryPage> createState() => _PasswordRecoveryPageState();
}

class _PasswordRecoveryPageState extends State<PasswordRecoveryPage> {
  final TextEditingController _emailController = TextEditingController();

  String? _errorMessage; // Variable to store error message

  // Password recovery method
  void resestPassword(BuildContext context) async {
    // Get an instance of the auth manager
    final AuthManager authManager = AuthManager();

    // Get the build context in relation to the navigator, scaffold messanger and themeData
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

    // Try reset password (Show snackbar if successful)
    try {
      if (_emailController.text != "") {
        await authManager.resetPassword(_emailController.text);
        showSnackbar(
          scaffoldMessenger,
          "Email sent to: ${_emailController.text}",
          Icon(Icons.check_circle, color: Colors.green),
          false,
        );
      } else {
        // Catch error if email is empty
        setState(() {
          _errorMessage = "Email is required";
        });
      }
    } catch (e) {
      // Catch exception
      setState(() {
        _errorMessage =
            e is Exception
                ? e.toString().replaceFirst('Exception: ', '')
                : e.toString();
      });
    }
    navigator.pop(); // Dismiss loading circle when finished
  }

  @override
  void dispose() {
    _emailController.dispose(); // Dispose of the controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Top bar
      appBar: AppBar(
        forceMaterialTransparency: true,
        leading: Padding(
          padding: const EdgeInsets.only(top: 10.0, left: 10),
          child: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Theme.of(context).colorScheme.primary,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ),
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
                    "Password Recovery",
                    style: TextStyle(
                      fontFamily: "Cabin",
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),

                // Subheading
                Padding(
                  padding: const EdgeInsets.only(left: 48.0, right: 48, top: 5),
                  child: Text(
                    "Enter your email address to receive a password reset link.",
                    style: TextStyle(
                      fontFamily: "Nunito",
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),

                SizedBox(height: 25),

                // Text field & button
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Email
                    PrimaryTextField(
                      label: "Email",
                      obscureText: false,
                      controller: _emailController,
                      errorMessage: _errorMessage,
                    ),

                    SizedBox(height: 35),

                    // Login button
                    Center(
                      child: PrimaryButton(
                        text: "Submit",
                        height: 45,
                        onPressed: () => resestPassword(context),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
