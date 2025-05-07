import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final void Function()? onPressed;

  const PrimaryButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF23565A),
        foregroundColor: Color(0xFFFAFAFA),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
        fixedSize: Size(318, 45),
      ),
      label: Text(text, style: TextStyle(fontFamily: "Montserrat", fontSize: 16),),
    );
  }
}
