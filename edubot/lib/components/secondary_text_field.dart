import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class SecondaryTextField extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;

  const SecondaryTextField({
    super.key,
    required this.controller,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: 200),
      child: TextField(
        controller: controller,
        enabled: enabled,
        textCapitalization: TextCapitalization.sentences,

        // Text field styling
        cursorColor: Theme.of(context).colorScheme.primary,
        style: TextStyle(
          color:
              enabled
                  ? Theme.of(context).colorScheme.onSecondary
                  : Theme.of(
                    context,
                  ).colorScheme.onSecondary.withValues(alpha: 0.75),
          fontFamily: 'Nunito',
        ),

        // Enable multiline text wrapping
        keyboardType: TextInputType.multiline,
        maxLines: null,
        scrollController: null,
        expands: false,

        // Style
        decoration: InputDecoration(
          isDense: kIsWeb ? true : false,
          contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 15),
          hintText: "Type a Message...",
          hintStyle: TextStyle(
            fontFamily: "Nunito",
            fontSize: 16,
            color: Theme.of(
              context,
            ).colorScheme.onSecondary.withValues(alpha: 0.75),
          ),

          // Background colour
          filled: true,
          fillColor:
              enabled
                  ? Theme.of(context).inputDecorationTheme.fillColor
                  : Theme.of(
                    context,
                  ).inputDecorationTheme.fillColor!.withValues(alpha: 0.5),

          // Border management
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(25),
          ),
        ),
      ),
    );
  }
}
