import 'package:edubot/components/custom_snack_bar.dart';
import 'package:edubot/components/primary_button.dart';
import 'package:edubot/services/firebase/firebase_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UpdateResponseLengthPage extends StatefulWidget {
  const UpdateResponseLengthPage({super.key});

  @override
  State<UpdateResponseLengthPage> createState() =>
      _UpdateResponseLengthPageState();
}

class _UpdateResponseLengthPageState extends State<UpdateResponseLengthPage> {
  // Determine the current slider value and track the original
  int? _currentValue;
  int? _originalValue;

  // Create a list of strings to associate the values with
  final List<String> tokenLengths = ["Concise", "Normal", "Lengthy"];

  // Update chatbot tone method
  Future<void> updateLength(BuildContext context) async {
    final firebaseProvider = Provider.of<FirebaseProvider>(context, listen: false);

    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    // Remove any snackbars if present
    scaffoldMessenger.removeCurrentSnackBar();

    // Show loading circle
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return Center(child: CircularProgressIndicator(color: Colors.blue));
      },
    );

    // Try update preferences, passing null for the other values
    try {
      await firebaseProvider.updatePreferences(_currentValue!.toInt(), null, null);

      // Display snack bar if successful
      showSnackbar(
        scaffoldMessenger,
        "Response Length updated successfully",
        Icon(Icons.check_circle, color: Colors.green),
        true,
      );
    } catch (e) {
      // Handle errors accordingly
      throw Exception("Error updating length: $e");
    }

    navigator.pop();
    navigator.pop();
  }

  // Load the chatbot response length from Firestore method and store it in both _currentValue and _originalValue
  void loadLength() async {
    final firebaseProvider = Provider.of<FirebaseProvider>(context, listen: false);
    final data = await firebaseProvider.getPreferences();

    if (data != null && mounted) {
      setState(() {
        _currentValue = data["length"];
        _originalValue = data["length"];
      });
    } else {
      // If the collection doesn't exist yet, set the values to 0
      setState(() {
        _currentValue = 0;
        _originalValue = 0;
      });
    }
  }

  // Load the current value for response length on initialisation
  @override
  void initState() {
    super.initState();
    loadLength();
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
            "Response Length",
            style: TextStyle(
              fontFamily: "Nunito",
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ),

      // Wait for vocab level to load and then display the result in a slider
      body:
          _currentValue == null
              ? Center(child: CircularProgressIndicator(color: Colors.blue))
              : SingleChildScrollView(
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 500),
                    // Initial description
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
                              "Adjust the slider to customise how long you wish EduBot's responses to be.",
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

                        // Display _currentValue above slider
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25),
                          child: Center(
                            child: Text(
                              tokenLengths[_currentValue!.toInt()],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: "Nunito",
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color:
                                    Theme.of(context).colorScheme.onSecondary,
                              ),
                            ),
                          ),
                        ),

                        // Response Length slider
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          child: Slider(
                            value: _currentValue!.toDouble(),
                            min: 0,
                            max: 2,
                            activeColor: Colors.blue.shade400,
                            inactiveColor: Colors.blue.shade100,
                            divisions: 2,
                            onChanged: (value) {
                              setState(() {
                                _currentValue = value.toInt();
                              });
                            },
                          ),
                        ),

                        SizedBox(height: 15),

                        // Confirmation button
                        PrimaryButton(
                          text: "Save",
                          height: 45,
                          onPressed:
                              _currentValue != _originalValue
                                  ? () => updateLength(context)
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
