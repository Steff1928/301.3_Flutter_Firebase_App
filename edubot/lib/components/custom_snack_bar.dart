import 'package:flutter/material.dart';

// Show a snackbar with custom parameters depending on the requirement
void showSnackbar(
  ScaffoldMessengerState scaffoldMessenger,
  String message,
  Icon icon,
  bool showCloseIcon,
) {
  final snackBar = SnackBar(
    content: Row(
      children: [
        icon,
        SizedBox(width: 16),
        Flexible(
          child: Text(
            message,
            style: TextStyle(fontFamily: "Nunito", fontSize: 16),
          ),
        ),
      ],
    ),
    behavior: SnackBarBehavior.floating,
    showCloseIcon: showCloseIcon,
  );

  scaffoldMessenger.showSnackBar(snackBar);
}
