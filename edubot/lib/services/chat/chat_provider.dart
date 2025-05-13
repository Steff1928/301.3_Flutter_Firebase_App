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

  Future<void> saveMessagesToFirestore() async {
    final firestore = FirebaseFirestore.instance;
    final AuthManager authManager = AuthManager();
    await firestore
        .collection("Messages")
        .doc(authManager.getCurrentUser()?.uid)
        .set({
          'messages': _messages.map((m) => m.toJson()).toList(),
          'lastMessageTimeStamp': DateTime.now().millisecondsSinceEpoch,
        });
  }

  void removeMessage() {
    _messages.removeRange(0, messages.length);
  }

  Future<void> loadMessagesFromFirestore() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final AuthManager authManager = AuthManager();
    final uid = authManager.getCurrentUser()?.uid;

    if (uid == null) return;

    final doc = await firestore.collection("Messages").doc(uid).get();

    if (doc.exists && doc.data()?['messages'] != null && uid == doc.id) {
      final List<dynamic> messagesJson = doc.data()!['messages'];
      final loadedMessages =
          messagesJson
              .map((json) => Message.fromJson(json as Map<String, dynamic>))
              .toList();

      _messages = loadedMessages;

      notifyListeners();
    }
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
      // Record the entire conversation and pass to the LlamaApiService (this will prompt chatbot memory)
      String context = _messages
          .map((m) => (m.isUser ? "User: " : "Bot: ") + m.content)
          .join("\n");
      final response = await _apiService.sendMessageToFlask(context);

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
