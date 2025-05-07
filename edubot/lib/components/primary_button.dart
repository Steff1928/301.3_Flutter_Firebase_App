import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final double width;
  final double height;
  final void Function()? onPressed;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.width,
    required this.height,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF23565A),
        foregroundColor: Color(0xFFFAFAFA),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        fixedSize: Size(width, height),
      ),
      label: Text(
        text,
        style: TextStyle(fontFamily: "Montserrat", fontSize: 16),
      ),
    );
  }
}
