import 'package:edubot/components/loading_anim.dart';
import 'package:edubot/services/chat/message.dart';
import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  // Get the required variables
  final Message message;
  final bool isLoading;
  final String? fileExtension;
  final int? fileSize;
  const ChatBubble({
    super.key,
    required this.message,
    this.isLoading = false,
    this.fileExtension,
    this.fileSize,
  });

  // Method to extract the file extension from it's name
  String? getFileExtension(String fileName) {
    if (fileName.contains('.')) {
      return '.${fileName.split('.').last}';
    }
    return null;
  }

  // Method to determine file size
  String? formatFileSize(int? bytes) {
    // Kilobytes & Megabytes storage values
    const int kb = 1024;
    const int mb = kb * 1024;

    // Ensure that the file bytes exist
    if (bytes != null) {
      if (bytes >= mb) {
        return '${(bytes / mb).toStringAsFixed(2)} MB';
      } else if (bytes >= kb) {
        return '${(bytes / kb).toStringAsFixed(2)} KB';
      } else {
        return '$bytes B';
      }
    } else {
      return null;
    }
  }

  // Method to determine the icon colour depending on the file extension
  Color getColourForExtension(String ext, BuildContext context) {
    switch (ext.toLowerCase()) {
      case '.pdf':
        return Theme.of(context).brightness == Brightness.dark
            ? Color(0xFFFF6B6C)
            : Colors.red;
      case '.txt':
        return Theme.of(context).brightness == Brightness.dark
            ? Colors.white60
            : Colors.black54;
      default:
        return Theme.of(context).brightness == Brightness.dark
            ? Color(0xFF96C0CA)
            : Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    String? ext;
    // If the message type was a file, get the file extension
    if (message.messageType == MessageType.file) {
      final extension = getFileExtension(message.content);
      ext = extension;
    }
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
          padding:
              message.messageType == MessageType.text
                  ? EdgeInsets.all(15)
                  : EdgeInsets.all(10),
          margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          decoration: BoxDecoration(
            color:
                message.isUser
                    ? Color(0xFF99DAE6)
                    : Theme.of(context).brightness == Brightness.dark
                    ? Color(0xFF364B55)
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Only display file container if the message type is "MessageType.file"
              if (message.messageType == MessageType.file)
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).brightness == Brightness.dark
                            ? Color(0xFF364B55)
                            : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(5),
                  ),

                  // File box
                  child: Row(
                    children: [
                      Icon(
                        Icons.description,
                        color: getColourForExtension(ext!, context),
                      ),
                      SizedBox(width: 12),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              message.content,
                              style: TextStyle(
                                fontFamily: "Nunito",
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color:
                                    Theme.of(context).colorScheme.onSecondary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 2),
                            Text(
                              '${ext.toUpperCase().replaceRange(0, 1, '')} | ${formatFileSize(fileSize)}',
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 14,
                                color:
                                    Theme.of(context).colorScheme.onSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              if (message.messageType == MessageType.text)
                // If AI message is loading, show loading animation, else display the message
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
                            color: Theme.of(context).colorScheme.onSecondary,
                          ),
                        ),
                      ],
                    )
                    : Text(
                      message.content,
                      style: TextStyle(
                        fontFamily: "Nunito",
                        fontSize: 16,
                        color:
                            !message.isUser
                                ? Theme.of(context).colorScheme.onSecondary
                                : Color(0xFF1A1A1A),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
