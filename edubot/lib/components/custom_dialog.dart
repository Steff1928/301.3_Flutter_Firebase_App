import 'package:flutter/material.dart';

class CustomDialog extends StatelessWidget {
  const CustomDialog({super.key, required this.onCancel, required this.onDelete});

  final void Function()? onCancel;
  final void Function()? onDelete;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SizedBox(
        height: 160,
        width: 500,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 5),

            // Warning Text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Text(
                "Delete Chat?",
                style: TextStyle(
                  fontFamily: "Nunito",
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),

            SizedBox(height: 5),

            Flexible(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Text(
                  "All associated memories with this chat will be deleted forever.",
                  style: TextStyle(
                    fontFamily: "Nunito",
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ),
            ),

            SizedBox(height: 15),

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  // Cancel
                  onPressed: onCancel,
                  child: Text(
                    "Cancel",
                    style: TextStyle(
                      fontFamily: "Nunito",
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
                // Delete
                TextButton(
                  onPressed: onDelete,
                  child: Text(
                    "Delete",
                    style: TextStyle(
                      fontFamily: "Nunito",
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
