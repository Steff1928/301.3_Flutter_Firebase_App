import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edubot/main.dart';
import 'package:edubot/services/authentication/auth_manager.dart';
import 'package:edubot/services/chat/llama_api_service.dart';
import 'package:edubot/services/chat/message.dart';
import 'package:edubot/services/firebase/firebase_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

class ChatProvider extends ChangeNotifier {
  // Get instance of Llama API Service
  final _apiService = LlamaApiService();

  // Get a list of messages & initialise loading state/empty AI message
  final List<Message> _messages = [];

  // Detect loading times
  bool _isLoading = false;
  bool _isEmptyAiMessageAdded = false;

  // Chatbot Preferences
  int? length;
  int? tone;
  int? vocabLevel;

  // Getters
  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;

  // Clear messages if they are not needed any more
  void clearMessages() {
    _messages.clear();
    notifyListeners();
  }

  // Remove message method
  void removeMessage() {
    _messages.removeRange(0, messages.length);
  }

  // Update the UI with new messages on first load
  void setMessages(List<Message> newMessages) {
    _messages
      ..clear()
      ..addAll(newMessages);
    notifyListeners(); // Update the UI as intended
  }

  /*

  LLM Response Methods

  */

  // Send message stream method (recieving and displaying incremental chunks)
  Future<void> sendStream(String content) async {
    final firebaseProvider = Provider.of<FirebaseProvider>(
      navigatorKey.currentContext!,
      listen: false,
    );

    // Set user message and add to chat
    final userMessage = Message(
      content: content,
      isUser: true,
      timeStamp: DateTime.now(),
    );

    _messages.add(userMessage);
    notifyListeners();

    // Start loading
    _isLoading = true;

    // Use this method to determine the state of the user's active conversation Id
    String? boundConversationId = await firebaseProvider.determineConversationId();
    List<Message> boundMessages = List.from(_messages);

    // Create empty AI message
    final aiMessage = Message(
      content: "",
      isUser: false,
      timeStamp: DateTime.now(),
    );

    bool receivedChunk = false;

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

      // Get the chat preferences from Firestore and assign them accordingly
      final data = await firebaseProvider.getPreferences();
      if (data != null) {
        length = data["length"];
        tone = data["tone"];
        vocabLevel = data["vocabLevel"];
      }

      // Send through a response to Flask server with formattedContext and chat preferences
      final stream = _apiService.streamMessageFromFlask(
        formattedContext,
        lastUserMessage.content,
        tone,
        vocabLevel,
        length,
      );

      notifyListeners(); // Update UI

      await for (final chunk in stream) {
        _isLoading = false;
        // Add the empty AI message only once
        if (!_isEmptyAiMessageAdded && chunk.isNotEmpty) {
          boundMessages.add(aiMessage);
          _messages.add(aiMessage);
          _isEmptyAiMessageAdded = true;
          notifyListeners();
        }

        // Append the chunk directly
        if (chunk.isNotEmpty) {
          receivedChunk = true;
          aiMessage.content += chunk;
          notifyListeners();
        }
      }
    } catch (e) {
      // Set error message
      final errorMessage = Message(
        content: 'Sorry I encountered an issue $e',
        isUser: false,
        timeStamp: DateTime.now(),
      );

      // Add error message to chat
      boundMessages.add(errorMessage);
      _messages.add(errorMessage);

      // Stop loading
      _isLoading = false;
    }

    // Reset _isEmptyAIMessageAdded state
    _isEmptyAiMessageAdded = false;

    // If a chunk was received, save messages to Firestore and generate title
    if (receivedChunk) {
      // Pass the boundConversationId and boundMessages to prevent interruption during
      // LLM response generation
      await firebaseProvider.saveMessagesToFirestore(boundConversationId, boundMessages);
      Future.microtask(() => generateTitle(boundConversationId, boundMessages));
    }
  }

  Future<void> generateTitle(
    String? conversationId,
    List<Message> contextMessages,
  ) async {
    // Get auth & firestore
    AuthManager authManager = AuthManager();
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      // Create a list of maps as a formattedContext to store message content and user/assistant roles from the current context
      List<Map<String, String>> formattedContext =
          contextMessages.map((m) {
            return {
              "role": m.isUser ? "user" : "assistant",
              "content": m.content,
            };
          }).toList();

      // Send through a response to Flask server with formattedContext
      final response = await _apiService.generateTitleFromFlask(
        formattedContext,
      );

      // Set the title in the Firestore document
      await firestore
          .collection("Users")
          .doc(authManager.getCurrentUser()?.uid)
          .collection('History')
          .doc(conversationId)
          .set(({
            'conversationId': conversationId,
            'description': contextMessages.last.content.replaceAll('\n', ' '),
            'title': response,
            'lastMessageTimeStamp': DateTime.now().millisecondsSinceEpoch,
          }));
    } catch (e) {
      // Handle errors
      throw Exception("Error generating title: $e");
    }
  }

  // Send through a file name and process the contents to generate a summary
  Future<void> sendFile(
    String fileName,
    String fileType,
    String filePath,
    Uint8List fileBytes,
    int fileSize,
  ) async {
    final firebaseProvider = Provider.of<FirebaseProvider>(
      navigatorKey.currentContext!,
      listen: false,
    );

    // Set user message
    final userMessage = Message(
      content: fileName,
      isUser: true,
      timeStamp: DateTime.now(),
      messageType: MessageType.file,
      fileSize: fileSize,
    );

    // Add user message to chat
    _messages.add(userMessage);

    // Update UI
    notifyListeners();

    // Start loading
    _isLoading = true;

    // Use this method to determine the state of the user's active conversation Id
    final String? boundConversationId = await firebaseProvider.determineConversationId();
    List<Message> boundMessages = List.from(_messages);

    // Update UI
    notifyListeners();

    // Try send file & recieve summary
    try {
      // Web
      if (kIsWeb) {
        // Get signedUrl from Flask (web)
        final signedUrl = await _apiService.getSignedUrlFromFlask(
          fileName,
          fileType,
        );

        await _apiService.uploadFileToS3Web(signedUrl, fileBytes, fileType);
        // Mobile/Desktop
      } else {
        // Get signedUrl from Flask
        final signedUrl = await _apiService.getSignedUrlFromFlask(
          fileName,
          fileType,
        );

        // Upload file to S3 using the signedUrl
        final file = File(filePath);
        await _apiService.uploadFileToS3(signedUrl, file, fileType);
      }

      // Send through a response to Flask server with formattedContext
      final response = await _apiService.processFileFromS3(fileName);

      // Assign the file content as a seperate message
      final fileContent = Message(
        content: response['og_text'],
        isUser: true,
        timeStamp: DateTime.now(),
        messageType: MessageType.fileContent
      );

      // Response message from Llama
      final responseMessage = Message(
        content: response['summary'],
        isUser: false,
        timeStamp: DateTime.now(),
      );

      // Add file content to messages lists (this will not be displayed on the UI)
      boundMessages.add(fileContent);
      _messages.add(fileContent);

      // Add response message to chat
      boundMessages.add(responseMessage);
      _messages.add(responseMessage);

    } catch (e) {
      // Set error message
      final errorMessage = Message(
        content: 'Sorry I encountered an issue $e',
        isUser: false,
        timeStamp: DateTime.now(),
      );

      // Add error message to chat
      boundMessages.add(errorMessage);
      _messages.add(errorMessage);
    }

    // Finished loading
    _isLoading = false;

    await firebaseProvider.saveMessagesToFirestore(boundConversationId, boundMessages);

    // Make sure all messages are persisted first
    await generateTitle(boundConversationId, boundMessages);

    notifyListeners(); // Finally update UI
  }
}
