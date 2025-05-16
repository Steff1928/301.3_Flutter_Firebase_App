import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edubot/components/chat_history_tile.dart';
import 'package:edubot/pages/chat_page.dart';
import 'package:edubot/services/authentication/auth_manager.dart';
import 'package:edubot/services/chat/chat_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatHistory extends StatefulWidget {
  const ChatHistory({super.key});

  @override
  State<ChatHistory> createState() => _ChatHistoryState();
}

class _ChatHistoryState extends State<ChatHistory> {
  List conversationItems = [];

  // Get conversation items from Firestore on page load
  Future<void> getConversationItems(BuildContext context) async {
    final firestore = FirebaseFirestore.instance;
    final AuthManager authManager = AuthManager();

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

    final querySnapshot =
        await firestore
            .collection('Users')
            .doc(authManager.getCurrentUser()?.uid)
            .collection('History')
            .get();

    setState(() {
      conversationItems = querySnapshot.docs.map((doc) => doc.data()).toList();
    });

    navigator.pop();
  }

  // TODO: Implement the rest of this function
  // Change the conversationId in Firestore
  Future<void> changeConversation(int index, BuildContext context) async {
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

    String? conversationId = await chatProvider.getSavedConversationId();

    final docSnapshotHistory =
        await firestore
            .collection('Users')
            .doc(authManager.getCurrentUser()?.uid)
            .collection('History')
            .get();

    final historyData =
        docSnapshotHistory.docs.map((doc) => doc.data()).toList();
    conversationId = historyData[index]['conversationId'];

    // Save activeConversationId
    firestore.collection("Users").doc(authManager.getCurrentUser()?.uid).update(
      {'activeConversationId': conversationId},
    );

    setState(() {
      chatProvider.loadMessagesFromFirestore();
    });

    // Remove all pages in the navigation stack
    if (authManager.getCurrentUser() != null) {
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => ChatPage()),
        (route) => false,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    getConversationItems(context);
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
          child: Consumer<ChatProvider>(
            builder: (context, chatProvider, child) {
              if (conversationItems.isEmpty) {
                return Center(child: Text("Empty")); // TODO: Style this
              }
              return ListView.builder(
                itemCount: conversationItems.length,
                itemBuilder: (context, index) {
                  return ChatHistoryTile(
                    title: '${conversationItems[index]['title']}',
                    description: "New Description",
                    onButtonPressed: () => changeConversation(index, context),
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
