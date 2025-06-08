import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edubot/services/authentication/auth_manager.dart';
import 'package:edubot/services/chat/llama_api_service.dart';
import 'package:edubot/services/chat/message.dart';
import 'package:flutter/foundation.dart';

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

  // Manage activeConversationId in Firebase if the user does not have one
  Future<String?> determineConversationId() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final AuthManager authManager = AuthManager();
    final String? uid = authManager.getCurrentUser()?.uid;

    // Get the saved conversationId
    String? conversationId = await getSavedConversationId();

    // Store the history in a subcollection called 'History' with temporary values ONLY if the a historyDoc does not already exist
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
          'title': 'Loading...', // TEMP
          'description': 'Loading...', // TEMP
        });
      }
    } else {
      // If conversationId is null, add a new document to 'Conversations' with a randomly generated ID
      final doc = await firestore
          .collection("Users")
          .doc(uid)
          .collection('Conversations')
          .add(({
            'messages': _messages.map((m) => m.toJson()).toList(),
            'lastMessageTimeStamp': DateTime.now().millisecondsSinceEpoch,
          }));

      conversationId = doc.id; // Assign the generated ID to conversationId

      // Save activeConversationId
      firestore.collection("Users").doc(uid).update({
        'activeConversationId': conversationId,
      });

      firestore
          .collection("Users")
          .doc(uid)
          .collection('History')
          .doc(conversationId)
          .set(({
            'conversationId': conversationId,
            'title': 'Loading...', // TEMP
            'description': 'Loading...', // TEMP
          }));
    }

    return conversationId;
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

  /*

  Firestore Methods (May be moved to another class later)

  */

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

  /*

  LLM Response Methods

  */

  // Send message stream method (recieving and displaying incremental chunks)
  Future<void> sendStream(String content) async {
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
    String? boundConversationId = await determineConversationId();
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
      final data = await getPreferences();
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
      await saveMessagesToFirestore(boundConversationId, boundMessages);
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
            'title': response,
            'description': contextMessages.last.content.replaceAll('\n', ' '),
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
    final String? boundConversationId = await determineConversationId();
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

    await saveMessagesToFirestore(boundConversationId, boundMessages);

    // Make sure all messages are persisted first
    await generateTitle(boundConversationId, boundMessages);

    notifyListeners(); // Finally update UI
  }
}
