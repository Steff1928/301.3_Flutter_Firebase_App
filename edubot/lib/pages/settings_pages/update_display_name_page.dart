import 'package:edubot/components/custom_snack_bar.dart';
import 'package:edubot/components/primary_button.dart';
import 'package:edubot/components/primary_text_field.dart';
import 'package:edubot/pages/chat_page.dart';
import 'package:edubot/services/authentication/auth_manager.dart';
import 'package:flutter/material.dart';

class UpdateDisplayNamePage extends StatefulWidget {
  const UpdateDisplayNamePage({super.key});

  @override
  State<UpdateDisplayNamePage> createState() => _UpdateDisplayNamePageState();
}

class _UpdateDisplayNamePageState extends State<UpdateDisplayNamePage> {
  final TextEditingController _displayNameController = TextEditingController();
  bool _isButtonEnabled = true;
  String? _errorMessage;

  Future<void> updateDisplayName(BuildContext context) async {
    AuthManager authManager = AuthManager();
    String newDisplayName = _displayNameController.text.trim();

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

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

    try {
      // Update the display name in the AuthManager
      await authManager.updateDisplayName(newDisplayName);
    } catch (e) {
      // Handle any errors that occur during the update
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      // Close the loading dialog
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => ChatPage()),
        (route) => false,
      );
    }

    // Show snackbar if update is successful
    showSnackbar(
      scaffoldMessenger,
      "Display Name updated successfully",
      Icon(Icons.check_circle, color: Colors.green),
      true,
    );
  }

  // Method to handle input changes and enable/disable the button
  void handleInputChange() {
    AuthManager authManager = AuthManager();
    setState(() {
      _isButtonEnabled =
          _displayNameController.text.isNotEmpty &&
          authManager.getCurrentUser()?.displayName!.toLowerCase() !=
              _displayNameController.text.toLowerCase().trim();
    });
  }

  @override
  void initState() {
    super.initState();
    // Initialize the display name controller with the current user's display name
    AuthManager authManager = AuthManager();
    _displayNameController.text =
        authManager.getCurrentUser()?.displayName ?? '';

    // Add listener to handle input changes
    _displayNameController.addListener(handleInputChange);

    // Call the input change handler initially to set the button state
    handleInputChange();
  }

  @override
  void dispose() {
    super.dispose();
    // Dispose of the controller to free up resources
    _displayNameController.dispose();
    // Remove the listener to prevent memory leaks
    _displayNameController.removeListener(handleInputChange);
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
            "Display Name",
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
                      "The name that will be used to address you in conversations with EduBot. You can change it at any time.",
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
                  controller: _displayNameController,
                  label: "Display Name",
                  obscureText: false,
                  errorMessage: _errorMessage,
                ),

                SizedBox(height: 25),

                PrimaryButton(
                  text: "Save",
                  height: 45,
                  onPressed:
                      _isButtonEnabled
                          ? () => updateDisplayName(context)
                          : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
