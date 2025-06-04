import 'package:flutter/material.dart';

class ErrorTile extends StatelessWidget {
  const ErrorTile({super.key, required this.errorMessage});

  final String errorMessage;

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Set the padding for the error tile and establish container style
      padding: const EdgeInsets.only(top: 10.0, left: 48, right: 48),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(width: 1, color: Theme.of(context).colorScheme.error),
          borderRadius: BorderRadius.circular(5),
          color: Colors.red.shade300.withValues(alpha: 0.25),
        ),
        padding: EdgeInsets.all(15),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 15.0),
              child: Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error),
            ),
            // Allow text wrapping
            Flexible(
              child: Text(
                errorMessage,
                style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.error),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
