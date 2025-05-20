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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Only display file container if _selectedFileName is not null
              if (message.messageType == MessageType.file)
                Row(
                  children: [
                    Icon(Icons.file_present_outlined, color: Color(0xFF1A1A1A)),
                    SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        message.content,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: "Nunito",
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                    ),
                  ],
                ),

              if (message.messageType == MessageType.text)
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
            ],
          ),
        ),
      ),
    );
  }
}
