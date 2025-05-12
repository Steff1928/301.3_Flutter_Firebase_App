import 'package:edubot/services/chat/llama_api_service.dart';
import 'package:edubot/services/chat/message.dart';
import 'package:flutter/material.dart';

class ChatProvider extends ChangeNotifier {
  // Get instance of Llama API Service
  final _apiService = LlamaApiService();

  // Get a list of messages & initialise loading state
  final List<Message> _messages = [];
  bool _isLoading = false;
  
  // Getters
  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;

  // Send message
  Future<void> sendMessage(String content) async {
    // Prevent empty sends
    if (content.trim().isEmpty) return;

    // Set user message
    final userMessage = Message(content: content, isUser: true, timeStamp: DateTime.now());

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
      final response = await _apiService.sendMessageToFlask(content);

      // Response message from Llama
      final responseMessage = Message(content: response, isUser: false, timeStamp: DateTime.now());

      // Add response message to chat
      _messages.add(responseMessage);
    } 
    catch (e) {
      // Set error message
      final errorMessage = Message(content: 'Sorry I encountered an issue $e', isUser: false, timeStamp: DateTime.now());

      // Add error message to chat
      _messages.add(errorMessage);
    }

    // Finished loading
    _isLoading = false;

    // Update UI
    notifyListeners();
  }


}