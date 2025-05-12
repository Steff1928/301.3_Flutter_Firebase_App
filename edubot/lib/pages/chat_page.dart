import 'package:edubot/components/chat_bubble.dart';
import 'package:edubot/components/secondary_text_field.dart';
import 'package:edubot/pages/chat_history.dart';
import 'package:edubot/pages/settings_page.dart';
import 'package:edubot/services/authentication/auth_manager.dart';
import 'package:edubot/services/chat/chat_provider.dart';
import 'package:edubot/services/chat/message.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _userInput = TextEditingController();

  String? getFirstName() {
    final AuthManager authManager = AuthManager();

    final fullName = authManager.getCurrentUser()?.displayName;
    final firstName = fullName.toString().split(" ")[0];

    return firstName;
  }

  void sendMessage() {
    final chatProvider = context.read<ChatProvider>();
    chatProvider.sendMessage(_userInput.text);
    _userInput.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Navgiation bar
      appBar: AppBar(
        forceMaterialTransparency: true,
        actionsPadding: EdgeInsets.symmetric(vertical: 10),
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            "Edubot",
            style: TextStyle(
              fontFamily: "Nunito",
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF074F67),
            ),
          ),
        ),

        // Navigation actions
        actions: [
          // TODO: Start new chat
          IconButton(
            icon: Icon(Icons.loupe_rounded, size: 24, color: Color(0xFF074F67)),
            onPressed: () {},
          ),
          // History
          IconButton(
            icon: Icon(
              Icons.history_rounded,
              size: 24,
              color: Color(0xFF074F67),
              weight: 30,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChatHistory()),
              );
            },
          ),
          // Settings
          IconButton(
            icon: Icon(
              Icons.settings_rounded,
              size: 24,
              color: Color(0xFF074F67),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage()),
              );
            },
          ),
        ],
      ),

      // Chat container
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Consumer<ChatProvider>(
                builder: (context, chatProvider, child) {
                  // If empty, display welcome message
                  if (chatProvider.messages.isEmpty) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Welcome, ${getFirstName()}",
                          style: TextStyle(
                            fontFamily: "Nunito",
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Start typing to get started",
                          style: TextStyle(
                            fontFamily: "Nunito",
                            fontSize: 16,
                            color: Color(0xFF364B55),
                          ),
                        ),
                      ],
                    );
                  }

                  // Return a list of messages from ChatProvider, both from roles 'user' and 'assistant'
                  return ListView.builder(
                    itemCount:
                        chatProvider.messages.length +
                        (chatProvider.isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      // If this is the last item we are loading, show the loading bubble
                      if (chatProvider.isLoading &&
                          index == chatProvider.messages.length) {
                        return ChatBubble(
                          message: Message(
                            content: "Loading...",
                            isUser: false,
                            timeStamp: DateTime.now(),
                          ),
                          isLoading: true,
                        );
                      }

                      // Get each message
                      final message = chatProvider.messages[index];

                      // return message
                      return ChatBubble(message: message);
                    },
                  );
                },
              ),
            ),

            // User input box
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // TO DO: Upload file functionality
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.folder_open_rounded,
                        size: 24,
                        color: Color(0xFF074F67),
                      ),
                    ),
                  ),

                  // User input box
                  Expanded(child: SecondaryTextField(controller: _userInput)),

                  // Send message button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color(0xFF2B656B),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: IconButton(
                        onPressed: sendMessage,
                        icon: Icon(Icons.send_rounded),
                        disabledColor: Colors.grey,
                        color: Color(0xFFFAFAFA),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
