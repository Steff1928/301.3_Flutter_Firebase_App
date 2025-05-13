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
    required this.timeStamp,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    final rawIsUser = json['isUser'];
    final isUser = rawIsUser is bool ? rawIsUser : rawIsUser.toString().toLowerCase() == 'true';

    return Message(
      content: json['content'],
      isUser: isUser,
      timeStamp: DateTime.parse(json['timeStamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'isUser': isUser,
      'timeStamp': timeStamp.toIso8601String(),
    };
  }
}
