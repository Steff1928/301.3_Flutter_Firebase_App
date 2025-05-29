import 'package:flutter/material.dart';

class SecondaryButton extends StatelessWidget {
  final String text;
  final double height;
  final void Function()? onPressed;

  const SecondaryButton({
    super.key,
    required this.text,
    required this.height,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // Set the width of the button to be full and add padding
      width: double.infinity,
      height: height,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 47.0),
        child: ElevatedButton.icon(
          onPressed: onPressed,
        
          // Decoration Style
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFFFAFAFA),
            foregroundColor: Color(0xFF05455B),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
          ),
          label: Text(
            text,
            style: TextStyle(fontFamily: "Montserrat", fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }
}
