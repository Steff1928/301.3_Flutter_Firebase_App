import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edubot/services/authentication/auth_manager.dart';
import 'package:edubot/services/chat/llama_api_service.dart';
import 'package:edubot/services/chat/message.dart';
import 'package:flutter/material.dart';

class ChatProvider extends ChangeNotifier {
  // Get instance of Llama API Service
  final _apiService = LlamaApiService();

  // Get a list of messages & initialise loading state/empty AI message
  final List<Message> _messages = [];
  bool _isLoading = false;
  bool _isEmptyAiMessageAdded = false;

  // Getters
  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;

  // Clear messages if they are not needed any more
  void clearMessages() {
    _messages.clear();
    notifyListeners();
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

  // Save messages to Firestore method
  Future<void> saveMessagesToFirestore() async {
    // Get instance of auth & firestore
    final firestore = FirebaseFirestore.instance;
    final AuthManager authManager = AuthManager();

    // Get conversationId from Firestore if it exists
    String? conversationId = await getSavedConversationId();

    // If conversationId is not null, open a document reference to designated conversation path
    if (conversationId != null) {
      await firestore
          .collection("Users")
          .doc(authManager.getCurrentUser()?.uid)
          .collection('Conversations')
          .doc(conversationId)
          .set(({
            'messages': _messages.map((m) => m.toJson()).toList(),
            'lastMessageTimeStamp': DateTime.now().millisecondsSinceEpoch,
          }));
    } else {
      // If conversationId is null, add a new document to 'Conversations' with a randomly generated ID
      final doc = await firestore
          .collection("Users")
          .doc(authManager.getCurrentUser()?.uid)
          .collection('Conversations')
          .add(({
            'messages': _messages.map((m) => m.toJson()).toList(),
            'lastMessageTimeStamp': DateTime.now().millisecondsSinceEpoch,
          }));

      conversationId = doc.id; // Assign the generated ID to conversationId
    }

    // Store the history in a subcollection called 'History'
    firestore
        .collection("Users")
        .doc(authManager.getCurrentUser()?.uid)
        .collection('History')
        .doc(conversationId)
        .set(({
          'conversationId': conversationId,
          'title': 'Loading...', // TEMP
          'description': messages.last.content.replaceAll('\n', ' '),
        }));

    generateTitle(); // Generate title

    // Save activeConversationId
    firestore.collection("Users").doc(authManager.getCurrentUser()?.uid).update(
      {'activeConversationId': conversationId},
    );
  }

  // Remove message method
  void removeMessage() {
    _messages.removeRange(0, messages.length);
  }

  Future<void> loadMessagesFromFirestore() async {
    //  Get instance of auth & firestore and set uid equal to the current user id
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final AuthManager authManager = AuthManager();
    final uid = authManager.getCurrentUser()?.uid;

    if (uid == null) return; // Return nothing if a uid could not be found

    try {
      final conversationId =
          await getSavedConversationId(); // Get the saved conversationId if it exists

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

        _messages.clear(); // Clear previous messages
        _messages.addAll(
          messagesRaw.map((msg) => Message.fromJson(msg)),
        ); // Format JSON data as a Message and add it to _messages
      }
    } catch (e) {
      throw Exception("Error fetching conversations: $e");
    }
    notifyListeners(); // Update UI
  }

  // Send message stream method (recieving and displaying incremental chunks)
  Future<void> sendStream(String content) async {
    // Prevent empty sends
    if (content.trim().isEmpty) return;

    // Set user message
    final userMessage = Message(
      content: content,
      isUser: true,
      timeStamp: DateTime.now(),
    );

    // Add user message to chat
    _messages.add(userMessage);

    // Update UI
    notifyListeners();

    // Start loading
    _isLoading = true;

    // Update UI
    notifyListeners();

    // Create empty AI message
    final aiMessage = Message(
      content: "",
      isUser: false,
      timeStamp: DateTime.now(),
    );

    // Try send message & recieve response
    try {
      // Get the last user message sent by the user
      final lastUserMessage = _messages.lastWhere((m) => m.isUser);

      // Establish the context without the last user message
      final contextMessages = _messages.sublist(
        0,
        _messages.lastIndexOf(lastUserMessage),
      );

      // Create a list of maps as a formattedContext to store message content and user/assistant roles from the previous context
      List<Map<String, String>> formattedContext =
          contextMessages.map((m) {
            return {
              "role": m.isUser ? "user" : "assistant",
              "content": m.content,
            };
          }).toList();

      // Send through a response to Flask server with formattedContext
      final stream = _apiService.streamMessageFromFlask(
        formattedContext,
        lastUserMessage.content,
      );

      // Wait for the chunk to recieved in stream and display the results
      await for (final chunk in stream) {
        _isLoading = false;

        // Add the empty AI message only once
        if (!_isEmptyAiMessageAdded) {
          _messages.add(aiMessage);
          _isEmptyAiMessageAdded = true;
        }

        // Append the chunk directly
        aiMessage.content += chunk;

        // Update UI
        notifyListeners();
      }
    } catch (e) {
      // Set error message
      final errorMessage = Message(
        content: 'Sorry I encountered an issue $e',
        isUser: false,
        timeStamp: DateTime.now(),
      );

      // Add error message to chat
      _messages.add(errorMessage);

      // Stop loading
      _isLoading = false;
    }

    // Reset _isEmptyAIMessageAdded state
    _isEmptyAiMessageAdded = false;

    // Update UI
    notifyListeners();

    // Save messages to Firestore
    await saveMessagesToFirestore();
  }

  // Send message method (recieving the full response)
  Future<void> sendMessage(String content) async {
    // Prevent empty sends
    if (content.trim().isEmpty) return;

    // Set user message
    final userMessage = Message(
      content: content,
      isUser: true,
      timeStamp: DateTime.now(),
    );

    // Add user message to chat
    _messages.add(userMessage);

    // Update UI
    notifyListeners();

    // Start loading
    _isLoading = true;

    // Update UI
    notifyListeners();

    // Try send message & recieve response
    try {
      // Get the last user message sent by the user
      final lastUserMessage = _messages.lastWhere((m) => m.isUser);

      // Establish the context without the last user message
      final contextMessages = _messages.sublist(
        0,
        _messages.lastIndexOf(lastUserMessage),
      );

      // Create a list of maps as a formattedContext to store message content and user/assistant roles from the previous context
      List<Map<String, String>> formattedContext =
          contextMessages.map((m) {
            return {
              "role": m.isUser ? "user" : "assistant",
              "content": m.content,
            };
          }).toList();

      // Send through a response to Flask server with formattedContext
      final response = await _apiService.sendMessageToFlask(
        formattedContext,
        lastUserMessage.content,
      );

      // Response message from Llama
      final responseMessage = Message(
        content: response,
        isUser: false,
        timeStamp: DateTime.now(),
      );

      // Add response message to chat
      _messages.add(responseMessage);
    } catch (e) {
      // Set error message
      final errorMessage = Message(
        content: 'Sorry I encountered an issue $e',
        isUser: false,
        timeStamp: DateTime.now(),
      );

      // Add error message to chat
      _messages.add(errorMessage);
    }

    // Finished loading
    _isLoading = false;

    // Update UI
    notifyListeners();

    // Save messages to Firestore
    await saveMessagesToFirestore();
  }

  Future<void> generateTitle() async {
    // Get auth & firestore
    AuthManager authManager = AuthManager();
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Get active conversation ID
    String? conversationId = await getSavedConversationId();

    try {
      // Create a list of maps as a formattedContext to store message content and user/assistant roles from the current context
      List<Map<String, String>> formattedContext =
          messages.map((m) {
            return {
              "role": m.isUser ? "user" : "assistant",
              "content": m.content,
            };
          }).toList();

      // Send through a response to Flask server with formattedContext
      final response = await _apiService.generateTitleFromFlask(
        formattedContext,
      );


      // Get the document to see if it exists (hasn't been deleted before loading title) and then update the title
      final doc =
          await firestore
              .collection('Users')
              .doc(authManager.getCurrentUser()?.uid)
              .collection('History')
              .doc(conversationId)
              .get();

      if (doc.exists) {
        await firestore
            .collection("Users")
            .doc(authManager.getCurrentUser()?.uid)
            .collection('History')
            .doc(conversationId)
            .update(({'title': response}));
      }
    } catch (e) {
      // Handle errors
      throw Exception("Error generating title: $e");
    }
  }
}
