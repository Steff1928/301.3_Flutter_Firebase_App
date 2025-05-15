import 'dart:async';

import 'package:edubot/components/chat_bubble.dart';
import 'package:edubot/components/loading_dialog.dart';
import 'package:edubot/components/secondary_text_field.dart';
import 'package:edubot/main.dart';
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
  // Get the required controllers
  final TextEditingController _userInput = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late List<Message> _previousMessages;

  bool _conversationHasLoaded = false; // Prevent multiple loads

  // Scroll to the bottom of the conversation upon inital chat page load (a bit janky but works well enough)
  void waitForMessagesThenScroll(ChatProvider chatProvider) async {
    // Wait for messages to load
    while (chatProvider.messages.isEmpty) {
      await Future.delayed(Duration(milliseconds: 50));
    }

    // Wait for build/layout
    await Future.delayed(Duration(milliseconds: 100));

    // Then wait until scroll metrics stabilize
    double previousExtent = -1;
    int retries = 10;

    while (_scrollController.hasClients &&
        _scrollController.position.maxScrollExtent != previousExtent &&
        retries > 0) {
      previousExtent = _scrollController.position.maxScrollExtent;
      await Future.delayed(Duration(milliseconds: 50));
      retries--;
    }

    // Final scroll to bottom
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  // Load message
  Future<void> loadMessages(BuildContext providerContext) async {
    // After widget tree is built, show loading circle with global context
    WidgetsBinding.instance.addPostFrameCallback((_) {
      navigatorKey.currentState?.push(
        PageRouteBuilder(
          opaque: false,
          pageBuilder: (_, _, __) => const Center(child: LoadingDialog()),
        ),
      );
    });

    // Try load message from Firestore using the global context
    try {
      await Provider.of<ChatProvider>(
        navigatorKey.currentContext!,
        listen: false,
      ).loadMessagesFromFirestore();
    } finally {
      // Safely close dialog
      if (navigatorKey.currentState?.canPop() ?? false) {
        navigatorKey.currentState?.pop();
      }
    }
  }

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      waitForMessagesThenScroll(chatProvider);
    });
  }

  // Only run this state when a dependency has changed
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Initialise previous messages
    _previousMessages = [];

    // Once dependency is changed, communicate with ChatProvider to load messages from Firestore (only do this once)
    if (!_conversationHasLoaded) {
      loadMessages(context);
      _conversationHasLoaded = true;
    }
  }

  // Get the user's first name in their display name
  String? getFirstName() {
    final AuthManager authManager = AuthManager();

    final fullName = authManager.getCurrentUser()?.displayName;
    final firstName = fullName.toString().split(" ")[0];

    return firstName;
  }

  // Send a response to ChatProvider
  void sendMessage() {
    final chatProvider = context.read<ChatProvider>();
    chatProvider.sendStream(_userInput.text);
    _userInput.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Top bar
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
                  // if (_isInitialLoad && chatProvider.hasLoadedInitialMessages) {
                  //   scrollToBottomAfterBuild(chatProvider.messages);
                  // }

                  // Scroll to most recent message sent if the message count has changed
                  // chatProvider.loadMessagesFromFirestore();
                  if (_previousMessages.length !=
                      chatProvider.messages.length) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (_scrollController.hasClients) {
                        _scrollController.animateTo(
                          _scrollController.position.maxScrollExtent,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                        );
                      }
                    });
                    _previousMessages = List.from(
                      chatProvider.messages,
                    ); // Add a copy of the messages to the previous messages
                  }

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
                    controller:
                        _scrollController, // Assign the scroll controller
                    // Add an additonal message onto the chat provider messages count if loading
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
                  // Attach file button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: IconButton(
                      onPressed: () {}, // TODO: Upload file functionality
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
