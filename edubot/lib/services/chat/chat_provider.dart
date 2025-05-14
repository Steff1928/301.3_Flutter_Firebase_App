import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edubot/services/authentication/auth_manager.dart';
import 'package:edubot/services/chat/llama_api_service.dart';
import 'package:edubot/services/chat/message.dart';
import 'package:flutter/material.dart';

class ChatProvider extends ChangeNotifier {
  // Get instance of Llama API Service
  final _apiService = LlamaApiService();

  // Get a list of messages & initialise loading state
  List<Message> _messages = [];
  bool _isLoading = false;

  // Getters
  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;

  // Save messages to Firestore method
  Future<void> saveMessagesToFirestore() async {
    // Get instance of auth & firestore
    final firestore = FirebaseFirestore.instance;
    final AuthManager authManager = AuthManager();

    // Save the list of messages to Firebase in JSON format
    await firestore
        .collection("Messages")
        .doc(authManager.getCurrentUser()?.uid)
        .set({
          'messages': _messages.map((m) => m.toJson()).toList(),
          'lastMessageTimeStamp': DateTime.now().millisecondsSinceEpoch,
        });
  }

  // Remove message method
  void removeMessage() {
    _messages.removeRange(0, messages.length);
  }

  // Get messages from Firestore database method
  Future<void> loadMessagesFromFirestore() async {
    // Get instance of auth & firestore and set uid equal to the current user id
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final AuthManager authManager = AuthManager();
    final uid = authManager.getCurrentUser()?.uid;

    if (uid == null) return; // Return nothing if a uid could not be found

    // Get and store the collection of messages in a variable with the uid in mind
    final doc = await firestore.collection("Messages").doc(uid).get();

    // If doc is not emptpy/exists and the uid matches the doc id, get the list of messages for that user account
    if (doc.exists && doc.data()?['messages'] != null && uid == doc.id) {
      final List<dynamic> messagesJson = doc.data()!['messages'];
      final loadedMessages =
          messagesJson
              .map((json) => Message.fromJson(json as Map<String, dynamic>))
              .toList();

      _messages = loadedMessages;

      notifyListeners(); // Update UI
    }
  }

  // Send message stream
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

    // Try send message & recieve response
    try {
      // Create empty AI message
      final aiMessage = Message(
        content: "",
        isUser: false,
        timeStamp: DateTime.now(),
      );

      _messages.add(aiMessage);
      notifyListeners();

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

      await for (final chunk in stream) {
        aiMessage.content += chunk;
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
    }

    // Finished loading
    _isLoading = false;

    // Update UI
    notifyListeners();

    // Save messages to Firestore
    await saveMessagesToFirestore();
  }

  // Send message
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
}
