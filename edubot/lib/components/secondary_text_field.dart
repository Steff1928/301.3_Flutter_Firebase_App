import 'package:flutter/material.dart';

class SecondaryTextField extends StatelessWidget {
  final TextEditingController controller;

  const SecondaryTextField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: 200
        ),
        child: TextField(
          controller: controller,

          // Text field styling
          cursorColor: Color(0xFF1A1A1A),
          style: TextStyle(color: Color(0xFF1A1A1A), fontFamily: 'Nunito'),
        
          // Enable multiline text wrapping
          keyboardType: TextInputType.multiline,
          maxLines: null,
          scrollController: null,
          expands: false,
        
          // Style
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            hintText: "Type a Message...",
            hintStyle: TextStyle(
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
              borderRadius: BorderRadius.circular(25),
            ),
          ),
        ),
      ),
    );
  }
}