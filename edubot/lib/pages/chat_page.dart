import 'package:edubot/components/secondary_text_field.dart';
import 'package:edubot/services/authentication/auth_manager.dart';
import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Navgiation bar
      appBar: AppBar(
        actionsPadding: EdgeInsets.only(right: 0, top: 10),
        title: Padding(
          padding: const EdgeInsets.only(left: 0, top: 10),
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
        actions: [
          IconButton(
            icon: Icon(Icons.loupe_rounded, size: 24, color: Color(0xFF074F67)),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(
              Icons.history_rounded,
              size: 24,
              color: Color(0xFF074F67),
              weight: 30,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(
              Icons.settings_rounded,
              size: 24,
              color: Color(0xFF074F67),
            ),
            onPressed: () {},
          ),
        ],
      ),

      // TODO: Chat container
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Welcome, ${getFirstName()}",
                      style: TextStyle(
                        fontFamily: "Nunito",
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A)
                      ),
                    ),
                    SizedBox(height: 10,),
                    Text(
                      "Start typing to get started",
                      style: TextStyle(
                        fontFamily: "Nunito",
                        fontSize: 16,
                        color: Color(0xFF364B55)
                      ),
                    ),

                  ],
                ),
              ),
            ),

            // User input box
            Row(
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
                      onPressed: () {},
                      icon: Icon(Icons.send_rounded, color: Color(0xFFFAFAFA)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
