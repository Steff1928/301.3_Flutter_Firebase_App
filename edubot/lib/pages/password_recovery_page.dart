import 'package:edubot/components/error_tile.dart';
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

  String? _errorMessage;

  // Password recovery method
  void resestPassword(BuildContext context) async {
    // Get an instance of the auth manager
    final AuthManager authManager = AuthManager();

    // Get the build context in relation to the navigator and scaffold messanger
    final navigator = Navigator.of(context);
    final scaffoldMessager = ScaffoldMessenger.of(context);

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

    // Try reset password
    try {
      if (_emailController.text != "") {
        await authManager.resetPassword(_emailController.text);
        final snackBar = SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 16),
              Flexible(
                child: Text(
                  "Email sent to: ${_emailController.text}",
                  style: TextStyle(fontFamily: "Nunito", fontSize: 16),
                ),
              ),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Color(0xFF1A1A1A),
        );
        scaffoldMessager.showSnackBar(snackBar);
      } else {
        // Email is required
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(top: 10.0, left: 10),
          child: IconButton(
            icon: Icon(Icons.arrow_back, color: Color(0xFF074F67)),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ),
      backgroundColor: Color(0xFFFAFAFA),
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
                      color: Color(0xFF074F67),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(left: 48.0, right: 48, top: 5),
                  child: Text(
                    "Enter your email address to receive a password reset link with instructions on what to do next.",
                    style: TextStyle(
                      fontFamily: "Nunito",
                      fontSize: 16,
                      color: Color(0xFF364B55),
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

                    SizedBox(height: 35),

                    // Login button
                    Center(
                      child: PrimaryButton(
                        text: "Submit",
                        width: 318,
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
