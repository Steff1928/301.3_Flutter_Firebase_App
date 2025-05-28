/*

Message class to structure message content
 
*/

// Determine whether the user message is a regular prompt or a file
enum MessageType {
  text,
  file,
  fileContent
}

class Message {
  // Assign variables to be stored in Firestore
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

  // Decode the data from JSON after it's been retrieved from Firestore
  factory Message.fromJson(Map<String, dynamic> json) {
    // Ensure isUser is a boolean variable
    final rawIsUser = json['isUser'];
    final isUser = rawIsUser is bool ? rawIsUser : rawIsUser.toString().toLowerCase() == 'true';

    // Return the Message with appropriate values
    return Message(
      content: json['content'],
      isUser: isUser,
      timeStamp: DateTime.parse(json['timeStamp']),
      messageType: MessageType.values.byName(json['messageType']),
    );
  }

  // Encode the data to JSON as it's being stored in Firestore
  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'isUser': isUser,
      'timeStamp': timeStamp.toIso8601String(),
      'messageType': messageType.name,
    };
  }
}
