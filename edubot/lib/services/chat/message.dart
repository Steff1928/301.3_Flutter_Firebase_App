/*
Message class to structure message content
 */

class Message {
  final String content;
  final bool isUser;
  final DateTime timeStamp;

  Message({
    required this.content,
    required this.isUser,
    required this.timeStamp
  });
}