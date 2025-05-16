import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edubot/components/chat_history_tile.dart';
import 'package:edubot/pages/chat_page.dart';
import 'package:edubot/services/authentication/auth_manager.dart';
import 'package:edubot/services/chat/chat_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatHistoryPage extends StatefulWidget {
  const ChatHistoryPage({super.key});

  @override
  State<ChatHistoryPage> createState() => _ChatHistoryPageState();
}

class _ChatHistoryPageState extends State<ChatHistoryPage> {
  // Change the conversationId in Firestore
  Future<void> changeConversation(
    String conversationId,
    BuildContext context,
  ) async {
    final firestore = FirebaseFirestore.instance;
    final AuthManager authManager = AuthManager();
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final navigator = Navigator.of(context);

    // Show loading circle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return Center(child: CircularProgressIndicator(color: Colors.blue));
        },
      );
    });

    String? currentConversationId = await chatProvider.getSavedConversationId();

    // Remove a conversation if has no data in it (eg. the user created a new conversation but didn't start it)
    if (chatProvider.messages.isEmpty) {
      await firestore
          .collection('Users')
          .doc(authManager.getCurrentUser()?.uid)
          .collection('Conversations')
          .doc(currentConversationId)
          .delete();
    }

    // Save activeConversationId
    await firestore
        .collection("Users")
        .doc(authManager.getCurrentUser()?.uid)
        .update({'activeConversationId': conversationId});

    chatProvider.loadMessagesFromFirestore();


    // Remove all pages in the navigation stack
    navigator.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => ChatPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Top bar
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(top: 10.0, left: 10),
          child: IconButton(
            icon: Icon(Icons.arrow_back, color: Color(0xFF074F67)),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        actionsPadding: EdgeInsets.only(top: 10),
        title: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Text(
            "Chat History",
            style: TextStyle(
              fontFamily: "Nunito",
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF074F67),
            ),
          ),
        ),
      ),

      // TODO: Add conversation history items
      body: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: SafeArea(
          child: StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance
                    .collection('Users')
                    .doc(AuthManager().getCurrentUser()?.uid)
                    .collection('History')
                    .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(color: Colors.blue),
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(child: Text("Empty")); // TODO: Style this
              }

              final conversationItems = snapshot.data!.docs;

              return ListView.builder(
                itemCount: conversationItems.length,
                itemBuilder: (context, index) {
                  final data =
                      conversationItems[index].data() as Map<String, dynamic>;
                  return ChatHistoryTile(
                    title: data['title'] ?? 'Untitled',
                    description: "New Description",
                    onButtonPressed:
                        () => changeConversation(
                          conversationItems[index].id,
                          context,
                        ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
