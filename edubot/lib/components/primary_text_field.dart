import 'package:flutter/material.dart';

class PrimaryTextField extends StatelessWidget {
  // Initialise variables
  final TextEditingController controller;
  final String label;
  final bool obscureText;
  final String? errorMessage; // Optional

  const PrimaryTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.obscureText,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Set the padding for the text field and establish required properties
      padding: const EdgeInsets.symmetric(horizontal: 47),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        
        // Text field styling
        style: TextStyle(color: Color(0xFF1A1A1A), fontFamily: 'Nunito'),
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
            color: errorMessage == null ? Color.fromARGB(200, 26, 26, 26) : Color(0xFFCC0000),
          ),

          // Background colour
          filled: true,
          fillColor: Color(0xFFE6E6E6),

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
