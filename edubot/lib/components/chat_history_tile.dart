import 'package:flutter/material.dart';

class ChatHistoryTile extends StatelessWidget {
  const ChatHistoryTile({
    super.key,
    required this.title,
    required this.description,
    required this.onButtonPressed,
    required this.onIconPressed,
  });

  // Define variables
  final String title;
  final String description;
  final void Function()? onButtonPressed;
  final void Function()? onIconPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // Set the width of the tile to be full and add padding
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 7.5),

        // Create an OutlinedButtom with rounded corners and shadow
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: Color(0xFF05455B),
            padding: EdgeInsets.only(left: 20, top: 20, bottom: 20, right: 10),
            side: BorderSide.none,
            backgroundColor: Color(0xFFF1F5F8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: onButtonPressed,
          // Set the button content to be a Row
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: "Nunito",
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF074F67),
                      ),
                    ),
                    Text(
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      description,
                      style: TextStyle(
                        fontFamily: "Nunito",
                        fontSize: 16,
                        color: Color(0xFF364B55),
                      ),
                    ),
                  ],
                ),
              ),
              // IconButton to delete converation item
              IconButton(
                onPressed: onIconPressed,
                icon: Icon(Icons.delete_rounded, color: Color(0xFFCC0000)),
                highlightColor: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
