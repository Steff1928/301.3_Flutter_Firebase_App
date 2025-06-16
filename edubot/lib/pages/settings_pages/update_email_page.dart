import 'package:edubot/components/custom_snack_bar.dart';
import 'package:edubot/components/primary_button.dart';
import 'package:edubot/components/primary_text_field.dart';
import 'package:edubot/pages/chat_page.dart';
import 'package:edubot/services/authentication/auth_manager.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UpdateEmailPage extends StatefulWidget {
  const UpdateEmailPage({super.key});

  @override
  State<UpdateEmailPage> createState() => _UpdateEmailPageState();
}

class _UpdateEmailPageState extends State<UpdateEmailPage> {
  final TextEditingController _emailController = TextEditingController();
  bool _isGoogleUser = false;
  bool _isButtonEnabled = true;
  String? _errorMessage;

  Future<void> updateEmail(BuildContext context) async {
    AuthManager authManager = AuthManager();
    String newEmail = _emailController.text.trim();

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    // Clear previous errors
    setState(() {
      _isButtonEnabled = true;
    });

    // Show loading circle
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return Center(child: CircularProgressIndicator(color: Colors.blue));
      },
    );

    try {
      // Update the email in the AuthManager
      await authManager.updateEmail(newEmail);
      showSnackbar(
        scaffoldMessenger,
        "Email sent to: ${_emailController.text}",
        Icon(Icons.check_circle, color: Colors.green),
        false,
      );
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => ChatPage()),
        (route) => false,
      );
    } catch (e) {
      // Handle any errors that occur during the update
      navigator.pop();
      setState(() {
        _errorMessage =
            e is Exception
                ? e.toString().replaceFirst('Exception: ', '')
                : e.toString();
      });
    }
  }

  // Method to check if the user is authenticated with Google
  Future<bool> isUserAuthenticatedWithGoogle() async {
    AuthManager authManager = AuthManager();
    final currentUser = authManager.getCurrentUser();

    if (currentUser != null) {
      // Check if the user is authenticated with Google
      for (final userInfo in currentUser.providerData) {
        if (userInfo.providerId == GoogleAuthProvider.PROVIDER_ID) {
          return true; // User is authenticated with Google
        }
      }
    }
    return false; // User is not authenticated with Google
  }

  void handleInputChange() {
    AuthManager authManager = AuthManager();
    // Enable the button only if the email is not empty and the user is not a Google user
    setState(() {
      _isButtonEnabled =
          _emailController.text.isNotEmpty &&
          authManager.getCurrentUser()?.email !=
              _emailController.text.toLowerCase().trim();
    });
  }

  @override
  void initState() {
    super.initState();
    // Initialize the email controller with the current user's email
    AuthManager authManager = AuthManager();
    _emailController.text = authManager.getCurrentUser()?.email ?? '';

    // Add listener to handle input changes
    _emailController.addListener(handleInputChange);

    // Call the input change handler initially to set the button state
    handleInputChange();

    // Check if the user is authenticated with Google
    isUserAuthenticatedWithGoogle().then((isGoogleUser) {
      setState(() {
        _isGoogleUser = isGoogleUser;
      });
    });

    // Re-run the check after async call
    handleInputChange();
  }

  @override
  void dispose() {
    super.dispose();
    // Dispose of the controller to free up resources
    _emailController.dispose();
    // Remove the listener to prevent memory leaks
    _emailController.removeListener(handleInputChange);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Top bar
      appBar: AppBar(
        centerTitle: true,
        forceMaterialTransparency: true,
        leading: Padding(
          padding: const EdgeInsets.only(top: 5.0, bottom: 5.0, left: 10.0),
          child: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Theme.of(context).colorScheme.primary,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            "Email",
            style: TextStyle(
              fontFamily: "Nunito",
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ),
      //  Main content + styling
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 500),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    left: 27.0,
                    right: 27,
                    top: 10,
                  ),
                  child: Center(
                    child: Text(
                      "Your account's email address. A verification email will be sent to this address if you change it.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: "Nunito",
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 50),

                PrimaryTextField(
                  controller: _emailController,
                  label: "Email",
                  obscureText: false,
                  isEnabled: _isGoogleUser ? false : true,
                  errorMessage: _errorMessage,
                ),

                SizedBox(height: 10),

                if (_isGoogleUser)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 48),
                    child: Text(
                      "Email address can't be changed while signed in with a Google account.",
                      style: TextStyle(
                        fontFamily: "Nunito",
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),

                SizedBox(height: 25),

                PrimaryButton(
                  text: "Save",
                  height: 45,
                  onPressed:
                      _isButtonEnabled ? () => updateEmail(context) : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
