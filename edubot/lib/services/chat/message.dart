/*
Message class to structure message content
 */

enum MessageType {
  text,
  file,
}

class Message {
  String content;
  final bool isUser;
  final DateTime timeStamp;
  final MessageType messageType;

  Message({
    required this.content,
    required this.isUser,
    required this.timeStamp,
    this.messageType = MessageType.text,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    final rawIsUser = json['isUser'];
    final isUser = rawIsUser is bool ? rawIsUser : rawIsUser.toString().toLowerCase() == 'true';

    return Message(
      content: json['content'],
      isUser: isUser,
      timeStamp: DateTime.parse(json['timeStamp']),
      messageType: json['messageType'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'isUser': isUser,
      'timeStamp': timeStamp.toIso8601String(),
      'messageType': messageType.toString(),
    };
  }
}
