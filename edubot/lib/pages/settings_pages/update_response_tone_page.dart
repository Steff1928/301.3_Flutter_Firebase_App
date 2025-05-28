import 'package:edubot/components/primary_button.dart';
import 'package:edubot/services/chat/chat_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UpdateResponseTonePage extends StatefulWidget {
  const UpdateResponseTonePage({super.key});

  @override
  State<UpdateResponseTonePage> createState() => _UpdateResponseTonePageState();
}

class _UpdateResponseTonePageState extends State<UpdateResponseTonePage> {
  // Determine the current slider value and track the original 
  int? _currentValue;
  int? _originalValue;

  // Create a list of strings to associate the values with
  final List<String> tones = ["Friendly", "Agressive", "Formal"];

  // Update chatbot tone method
  Future<void> updateTone(BuildContext context) async {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
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
      await chatProvider.updatePreferences(null, _currentValue!.toInt(), null);
      // Display snack bar if successful
      final snackBar = SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 16),
            Flexible(
              child: Text(
                "Response Tone updated successfully.",
                style: TextStyle(fontFamily: "Nunito", fontSize: 16),
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Color(0xFF1A1A1A),
        showCloseIcon: true,
      );
      scaffoldMessenger.showSnackBar(snackBar);
    } catch (e) {
      // Handle errors accordingly
      throw Exception("Error updating length: $e");
    }

    // Remove loading indiactor and go back to settings screen
    navigator.pop();
    navigator.pop();
  }

  // Load the chatbot response tone from Firestore method and store it in both _currentValue and _originalValue
  void loadTone() async {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final data = await chatProvider.getPreferences();

    if (data != null && mounted) {
      setState(() {
        _currentValue = data["tone"];
        _originalValue = data["tone"];
      });
    } else {
      // If the collection doesn't exist yet, set the values to 0
      setState(() {
        _currentValue = 0;
        _originalValue = 0;
      });
    }
  }

  // Load the current value for response tone on initialisation
  @override
  void initState() {
    super.initState();
    loadTone();
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
            icon: Icon(Icons.arrow_back, color: Color(0xFF074F67)),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            "Response Tone",
            style: TextStyle(
              fontFamily: "Nunito",
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF074F67),
            ),
          ),
        ),
      ),

      // Wait for vocab level to load and then display the result in a slider
      body:
          _currentValue == null
              ? Center(
                child: const CircularProgressIndicator(color: Colors.blue),
              )
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
                              "Adjust the slider to set the behaviour at which EduBot should respond to your queries.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: "Nunito",
                                fontSize: 16,
                                color: Color(0xFF364B55),
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
                              tones[_currentValue!.toInt()],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: "Nunito",
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                          ),
                        ),

                        // Response Tone slider
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

                        // Confimation button
                        PrimaryButton(
                          text: "Save",
                          height: 45,
                          onPressed:
                              _currentValue != _originalValue
                                  ? () => updateTone(context)
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
