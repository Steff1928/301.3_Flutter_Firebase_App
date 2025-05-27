import 'package:flutter/material.dart';

class PrimaryTextField extends StatelessWidget {
  // Initialise variables
  final TextEditingController controller;
  final String label;
  final bool obscureText;
  final String? errorMessage; // Optional
  final bool isEnabled; // Default to true, can be set later

  const PrimaryTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.obscureText,
    this.errorMessage,
    this.isEnabled = true, // Allow enabling/disabling the text field
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Set the padding for the text field and establish required properties
      padding: const EdgeInsets.symmetric(horizontal: 47),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        enabled: isEnabled, // Use the isEnabled property to control the field's state
        
        // Text field styling
        style: TextStyle(color: isEnabled ? Color(0xFF1A1A1A) : Color(0xFF1A1A1A).withValues(alpha: 0.75), fontFamily: 'Nunito'),
        cursorColor: Color(0xFF074F67),
        

        // Decoration Style
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          labelText: label,
          error: errorMessage != null ? Padding(
            padding: const EdgeInsets.only(top: 5.0),
            child: Row(
              children: [
                Icon(Icons.error, color: Color(0xFFCC0000), size: 24,),
                SizedBox(width: 10,),
                Text("$errorMessage", style: TextStyle(color: Color(0xFFCC0000)),),
              ],
            ),
          ) : null,
          labelStyle: TextStyle(
            fontFamily: "Nunito",
            fontSize: 16,
            color: errorMessage == null ? Color(0xFF1A1A1A).withValues(alpha: 0.75) : Color(0xFFCC0000),
          ),

          // Background colour
          filled: true,
          fillColor: isEnabled ? Color(0xFFE6E6E6) : Color(0xFFE6E6E6).withValues(alpha: 0.5),

          // Border management
          border: OutlineInputBorder(
            borderSide: errorMessage == null ? BorderSide.none : BorderSide(),
            borderRadius: BorderRadius.circular(5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide(color: Colors.blue, width: 1),
          ),
        ),
      ),
    );
  }
}
