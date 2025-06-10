import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edubot/components/chat_history_tile.dart';
import 'package:edubot/components/custom_dialog.dart';
import 'package:edubot/pages/chat_page.dart';
import 'package:edubot/services/authentication/auth_manager.dart';
import 'package:edubot/services/chat/chat_provider.dart';
import 'package:edubot/services/firebase/firebase_provider.dart';
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
    final firebaseProvider = Provider.of<FirebaseProvider>(
      context,
      listen: false,
    );
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

    // Get the current conversation ID
    String? currentConversationId =
        await firebaseProvider.getSavedConversationId();

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

    // Only load if switching to a different conversation
    if (currentConversationId != conversationId) {
      await firebaseProvider.loadMessagesFromFirestore();
      // Remove all pages in the navigation stack
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => ChatPage()),
        (route) => false,
      );
    } else {
      navigator.pop(); // Close the loading dialog early
      navigator.pop(); // Close the Chat History page
    }
  }

  // Delete conversation item method
  Future<void> deleteConversation(
    String conversationId,
    BuildContext context,
  ) async {
    Navigator.of(context).pop();

    // Get auth & firestore
    final firestore = FirebaseFirestore.instance;
    final AuthManager authManager = AuthManager();

    // Get ChatProvider to access the current list of messages
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    // Get FirebaseProvider to access Firestore methods
    final firebaseProvider = Provider.of<FirebaseProvider>(
      context,
      listen: false,
    );

    // Delete the converation and history item corresponding to conversationID
    await firestore
        .collection('Users')
        .doc(authManager.getCurrentUser()?.uid)
        .collection('Conversations')
        .doc(conversationId)
        .delete();

    await firestore
        .collection('Users')
        .doc(authManager.getCurrentUser()?.uid)
        .collection('History')
        .doc(conversationId)
        .delete();

    // Get the active conversation ID
    String? currentConversationId =
        await firebaseProvider.getSavedConversationId();

    // If the the converation the user wanted to delete is the same one that is currently in their chat view,
    // clear messages
    setState(() {
      if (conversationId == currentConversationId) {
        chatProvider.clearMessages();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Top bar
      appBar: AppBar(
        forceMaterialTransparency: true,
        leading: Padding(
          padding: const EdgeInsets.only(top: 5.0, bottom: 5.0, left: 10),
          child: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Theme.of(context).colorScheme.primary,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            "Chat History",
            style: TextStyle(
              fontFamily: "Nunito",
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ),

      // Create a StreamBuilder which listens to the snapshots in the "History" subcollection
      body: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: SafeArea(
          child: StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance
                    .collection('Users')
                    .doc(AuthManager().getCurrentUser()?.uid)
                    .collection('History')
                    .orderBy('lastMessageTimeStamp', descending: true)
                    .snapshots(),
            builder: (context, snapshot) {
              // Show loading indicator
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(color: Colors.blue),
                );
              }

              // If Chat History is empty, display a default message
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'lib/assets/images/no-chats.png',
                        width: 207,
                        height: 207,
                      ),
                      SizedBox(height: 30),
                      Text(
                        "No Conversations to Show",
                        style: TextStyle(
                          fontFamily: "Nunito",
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSecondary,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Chat with Edubot to create one",
                        style: TextStyle(
                          fontFamily: "Nunito",
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                );
              }

              // Get the list of converation items from the snapshot data
              final conversationItems = snapshot.data!.docs;

              // Add all the converation items to a ListView
              return ListView.builder(
                itemCount: conversationItems.length,
                itemBuilder: (context, index) {
                  final data =
                      conversationItems[index].data() as Map<String, dynamic>;
                  return ChatHistoryTile(
                    title: data['title'] ?? 'Untitled',
                    description: data['description'] ?? 'Untitled',
                    onButtonPressed:
                        () => changeConversation(
                          conversationItems[index].id,
                          context,
                        ),
                    onIconPressed:
                        () => showDialog(
                          context: context,
                          builder: (context) {
                            return CustomDialog(
                              onCancel: () => Navigator.of(context).pop(),
                              onDelete:
                                  () => deleteConversation(
                                    conversationItems[index].id,
                                    context,
                                  ),
                            );
                          },
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
