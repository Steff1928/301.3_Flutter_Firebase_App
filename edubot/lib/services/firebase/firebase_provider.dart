import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edubot/main.dart';
import 'package:edubot/services/authentication/auth_manager.dart';
import 'package:edubot/services/chat/chat_provider.dart';
import 'package:edubot/services/chat/message.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FirebaseProvider extends ChangeNotifier {
  /*

  Firebase Methods

  */

  // Update chatbot preferences method
  Future<void> updatePreferences(
    int? length,
    int? tone,
    int? vocabLevel,
  ) async {
    // Get an instance of Firestore and AuthManager
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final AuthManager authManager = AuthManager();
    // Assign the uid
    final String? uid = authManager.getCurrentUser()?.uid;

    // Store a reference to the "Preferences" subcollection and get the document
    final preferenceDocRef = firestore
        .collection("Users")
        .doc(uid)
        .collection("Preferences")
        .doc(uid);
    final preferenceDoc = await preferenceDocRef.get();

    // If the "Preferences" subcollection does not exist, create it with initial values
    if (!preferenceDoc.exists) {
      await preferenceDocRef.set({
        'length': length ?? 0,
        'tone': tone ?? 0,
        'vocabLevel': vocabLevel ?? 0,
      });
    } else {
      // Based on the preference passed, update the data within Firestore using the reference
      if (length != null) {
        await preferenceDocRef.update({'length': length});
      } else if (tone != null) {
        await preferenceDocRef.update({'tone': tone});
      } else if (vocabLevel != null) {
        await preferenceDocRef.update({'vocabLevel': vocabLevel});
      }
    }
  }

  // Get the chatbot preferences method
  Future<Map<String, dynamic>?> getPreferences() async {
    // Get an instance of Firestore and AuthManager
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final AuthManager authManager = AuthManager();
    // Assign the uid
    final String? uid = authManager.getCurrentUser()?.uid;

    // Store a reference to the "Preferences" subcollection and get the document
    final preferenceDocRef = firestore
        .collection("Users")
        .doc(uid)
        .collection("Preferences")
        .doc(uid);
    final preferenceDoc = await preferenceDocRef.get();

    // Store the data in a seperate variable
    final data = preferenceDoc.data();

    // If the "Preferences" subcollection exists, return the data
    if (preferenceDoc.exists) {
      return data;
    } else {
      // Before returning null, set preferences in case the collection doesn't exist yet
      preferenceDocRef.set({'length': 0, 'tone': 0, 'vocabLevel': 0});
      return null;
    }
  }

  // Get conversationId from Firestore method
  Future<String?> getSavedConversationId() async {
    // Get instance of auth & firestore
    final AuthManager authManager = AuthManager();
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Get the currently signed in user
    final doc =
        await firestore
            .collection('Users')
            .doc(authManager.getCurrentUser()?.uid)
            .get();

    final data = doc.data(); // Assign the data to a variable

    // If the user exists and the conversationId is not null, return it
    if (data != null && data['activeConversationId'] != null) {
      return data['activeConversationId'] as String;
    }
    return null; // Otherwise, return null
  }

  // Manage activeConversationId in Firebase if the user does not have one
  Future<String?> determineConversationId() async {
    // Get instance of auth & firestore and set uid equal to the current user id
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final AuthManager authManager = AuthManager();
    final String? uid = authManager.getCurrentUser()?.uid;

    // Assign the chatProvider
    final chatProvider = Provider.of<ChatProvider>(
      navigatorKey.currentContext!,
      listen: false,
    );

    // Get the saved conversationId
    String? conversationId = await getSavedConversationId();

    // Store the history in a subcollection called 'History' with temporary values ONLY 
    // if a historyDoc does not already exist
    if (conversationId != null) {
      final historyDocRef = firestore
          .collection("Users")
          .doc(uid)
          .collection("History")
          .doc(conversationId);

      final historyDoc = await historyDocRef.get();
      if (!historyDoc.exists) {
        await historyDocRef.set({
          'conversationId': conversationId,
          'description': 'Loading...', // TEMP
          'title': 'Loading...', // TEMP
          'lastMessageTimeStamp': DateTime.now().millisecondsSinceEpoch,
        });
      }
    } else {
      // If conversationId is null, add a new document to 'Conversations' with a randomly generated ID
      final doc = await firestore
          .collection("Users")
          .doc(uid)
          .collection('Conversations')
          .add(({
            'messages': chatProvider.messages.map((m) => m.toJson()).toList(),
            'lastMessageTimeStamp': DateTime.now().millisecondsSinceEpoch,
          }));

      conversationId = doc.id; // Assign the generated ID to conversationId

      // Save activeConversationId
      firestore.collection("Users").doc(uid).update({
        'activeConversationId': conversationId,
      });

      // Create a history document with temporary values
      firestore
          .collection("Users")
          .doc(uid)
          .collection('History')
          .doc(conversationId)
          .set(({
            'conversationId': conversationId,
            'description': 'Loading...', // TEMP
            'title': 'Loading...', // TEMP
            'lastMessageTimeStamp': DateTime.now().millisecondsSinceEpoch,
          }));
    }

    return conversationId;
  }

  // Save messages to Firestore method
  Future<void> saveMessagesToFirestore(
    String? conversationId,
    List<Message> contextMessages,
  ) async {
    // Get instance of auth & firestore
    final firestore = FirebaseFirestore.instance;
    final AuthManager authManager = AuthManager();

    // If conversationId is not null, open a document reference to designated conversation path
    await firestore
        .collection("Users")
        .doc(authManager.getCurrentUser()?.uid)
        .collection('Conversations')
        .doc(conversationId)
        .set(({
          'messages': contextMessages.map((m) => m.toJson()).toList(),
          'lastMessageTimeStamp': DateTime.now().millisecondsSinceEpoch,
        }));
  }

  // Load messages from Firestore method
  Future<void> loadMessagesFromFirestore() async {
    //  Get instance of auth & firestore and set uid equal to the current user id
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final AuthManager authManager = AuthManager();
    final uid = authManager.getCurrentUser()?.uid;

    final chatProvider = Provider.of<ChatProvider>(
      navigatorKey.currentContext!,
      listen: false,
    );

    if (uid == null) return; // Return nothing if a uid could not be found

    try {
      // Get the saved conversationId if it exists
      final conversationId = await getSavedConversationId();

      // Get all conversations for the user where conversationId matches the activeConversationId
      final docSnapshot =
          await firestore
              .collection('Users')
              .doc(uid)
              .collection('Conversations')
              .doc(conversationId)
              .get();

      // Return nothing if no conversations exists
      if (!docSnapshot.exists) {
        return;
      }

      final data =
          docSnapshot
              .data(); // Assign the conversation data to a seperate variable

      // If conversation data exists, append the data to the _messages list
      if (data != null && data['messages'] != null) {
        final messagesRaw = List<Map<String, dynamic>>.from(
          data['messages'],
        ); // Get the raw JSON data

        chatProvider.setMessages(
          messagesRaw.map((msg) => Message.fromJson(msg)).toList(),
        ); // Format JSON data as a Message and add it to _messages
      }
    } catch (e) {
      throw Exception("Error fetching conversations: $e");
    }

    notifyListeners(); // Update UI
  }
}
