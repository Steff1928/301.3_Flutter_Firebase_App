import 'package:flutter/material.dart';

class PrimaryTextField extends StatelessWidget {
  // Initialise variables
  final TextEditingController controller;
  final String label;
  final bool obscureText;

  const PrimaryTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.obscureText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 47),
      child: TextField(
        controller: controller,
        obscureText: obscureText,

        // Style
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          labelText: label,
          labelStyle: TextStyle(
            fontFamily: "Nunito",
            fontSize: 16,
            color: Color.fromARGB(200, 26, 26, 26),
          ),
          
          // Background colour
          filled: true,
          fillColor: Color(0xFFE6E6E6),

          // Border management
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
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
