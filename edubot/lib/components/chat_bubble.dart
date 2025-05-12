import 'package:edubot/components/loading_anim.dart';
import 'package:edubot/services/chat/message.dart';
import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  // Get the message and loading state
  final Message message;
  final bool isLoading;
  const ChatBubble({super.key, required this.message, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment:
          message.isUser
              ? Alignment.centerRight
              : Alignment
                  .centerLeft, // Check if the message is from the user and align accordingly
      // Set the padding based on the message sender
      child: Padding(
        padding:
            message.isUser
                ? const EdgeInsets.only(left: 75)
                : const EdgeInsets.only(left: 0),
        child: Container(
          padding: EdgeInsets.all(15),
          margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          decoration: BoxDecoration(
            color:
                message.isUser
                    ? Color(0xFF99DAE6)
                    : Color(
                      0xFFF0F0F0,
                    ), // Set the background color based on the message sender
            // Set the border radius based on the message sender
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
              bottomLeft: message.isUser ? Radius.circular(12) : Radius.zero,
              bottomRight: message.isUser ? Radius.zero : Radius.circular(12),
            ),
          ),
          // If AI message is loading, show loading animation, else display the message
          child:
              isLoading
                  ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const LoadingAnim(),
                      SizedBox(width: 16),
                      Text(
                        message.content,
                        style: TextStyle(
                          fontFamily: "Nunito",
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                    ],
                  )
                  : Text(
                    message.content,
                    style: TextStyle(
                      fontFamily: "Nunito",
                      fontSize: 16,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
        ),
      ),
    );
  }
}
