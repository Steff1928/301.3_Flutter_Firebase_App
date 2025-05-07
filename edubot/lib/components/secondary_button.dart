import 'package:flutter/material.dart';

class SecondaryButton extends StatelessWidget {
  final String text;
  final void Function()? onPressed;

  const SecondaryButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFFFAFAFA),
        foregroundColor: Color(0xFF05455B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
        fixedSize: Size(318, 45),
      ),
      label: Text(text, style: TextStyle(fontFamily: "Montserrat", fontSize: 16),),
    );
  }
}
