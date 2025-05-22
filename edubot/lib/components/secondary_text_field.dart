import 'package:flutter/material.dart';

class SecondaryTextField extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;

  const SecondaryTextField({super.key, required this.controller, required this.enabled});

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
          enabled: enabled,

          // Text field styling
          cursorColor: Color(0xFF1A1A1A),
          style: TextStyle(color: enabled ? Color(0xFF1A1A1A) : Color(0xFF1A1A1A).withValues(alpha: 0.75) , fontFamily: 'Nunito'),
        
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
              color: Color(0xFF1A1A1A).withValues(alpha: 0.75),
            ),
            
            // Background colour
            filled: true,
            fillColor: enabled ? Color(0xFFE6E6E6) : Color(0xFFE6E6E6).withValues(alpha: 0.5),
        
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