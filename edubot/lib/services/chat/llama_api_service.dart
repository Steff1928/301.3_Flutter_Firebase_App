import 'dart:convert';
import 'dart:io';
import 'package:edubot/services/authentication/auth_manager.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/*

Service class to handle Llama API

*/

class LlamaApiService {
  // Flask Url (Android IP: 10.0.2.2 - Web IP: localhost or 127.0.0.0 - AWS IP: 54.153.130.139)
  final String uri = kIsWeb ? 'http://localhost:5001' : 'http://10.0.2.2:5001';
  final user = FirebaseAuth.instance.currentUser;

  // Sends a message to the Flask server and returns a stream of responses.
  Stream<String> streamMessageFromFlask(
    List<Map<String, String>> context,
    String message,
    int? tone,
    int? vocabLevel,
    int? length,
  ) async* {
    final AuthManager authManager = AuthManager();

    // Get the ID token
    final idToken = await user?.getIdToken();

    if (idToken == null) {
      throw Exception(
        "Unable to get Firebase ID token. User may not be logged in.",
      );
    }

    // Assign the URL
    final url = Uri.parse('$uri/stream_chat');
    // Assign the body with context, message, and display name
    final body = {
      'context': context,
      'message': message,
      'displayName': authManager.getCurrentUser()?.displayName,
      'tone': tone ?? 0,
      'vocab_complexity': vocabLevel ?? 0,
      'token_length': length ?? 0,
    };

    // Create a POST request with the URL and headers
    final request =
        http.Request('POST', url)
          ..headers['Content-Type'] = 'application/json'
          ..headers['Authorization'] = 'Bearer $idToken'
          ..body = jsonEncode(body);

    // Await the response from the server and store the streamed response
    final response = await request.send();
    final stream = response.stream.transform(utf8.decoder);

    // Initialize a buffer to accumulate chunks
    String buffer = '';

    await for (var chunk in stream) {
      // Append the chunk to the buffer
      buffer += chunk;

      // Split on newlines to process full lines
      final lines = buffer.split('\n');

      // Keep the last line in buffer if it may be incomplete
      buffer = lines.removeLast();

      // Process each line and format accordigly
      for (final line in lines) {
        final cleaned = line.replaceFirst(RegExp(r'^data:\s*'), '').trim();

        if (cleaned.toLowerCase().contains('[done]') || cleaned.isEmpty) {
          continue;
        }

        try {
          // Attempt to parse the cleaned line as JSON and yield the content
          final jsonData = json.decode(cleaned);
          final content = jsonData['message']?['content'];
          if (content is String) yield content;
        } catch (e) {
          // Don't yield anything broken in terms of JSON parsing
          throw Exception('JSON parse error: $e\nLine: $cleaned');
        }
      }
    }

    // Try to process any leftover line
    if (buffer.isNotEmpty) {
      // Clean the buffer and attempt to parse it as JSON
      final cleaned = buffer.replaceFirst(RegExp(r'^data:\s*'), '').trim();
      try {
        final jsonData = json.decode(cleaned);
        final content = jsonData['message']?['content'];
        if (content is String) yield content;
      } catch (e) {
        // If the final buffer cannot be parsed, throw an error
        throw Exception('Final JSON parse error: $e\nBuffer: $cleaned');
      }
    }
  }

  // Send a message and recieve a concise summary of the conversation
  Future<String> generateTitleFromFlask(
    List<Map<String, String>> context,
  ) async {
    // Get the ID token
    final idToken = await user?.getIdToken();

    if (idToken == null) {
      throw Exception(
        "Unable to get Firebase ID token. User may not be logged in.",
      );
    }

    final url = Uri.parse('$uri/make_title');

    // Headers
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $idToken',
    };

    // JSON Payload
    final body = jsonEncode({"context": context});

    // Try send post request to Flask server
    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['title'];
      } else {
        throw Exception("Server error: ${response.statusCode}");
      }
    } catch (e) {
      // Handle errors
      throw Exception("Request failed: $e");
    }
  }

  /* 
    
  File Methods 
  
  */

  // Get a pre-signed URL from Flask to recieve S3 URL
  Future<String> getSignedUrlFromFlask(String fileName, String fileType) async {
    final url = Uri.parse('$uri/generate-upload-url');

    // Headers
    final headers = {'Content-Type': 'application/json'};

    // JSON Payload
    final body = jsonEncode({"filename": fileName, "content_type": fileType});

    try {
      // Send a POST request to the Flask server to get the signed URL
      final response = await http.post(url, headers: headers, body: body);
      // Check if the response is successful and parse the JSON response
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['upload_url'];
      } else {
        // If the response is not successful, throw an error
        throw Exception("Server error: ${response.statusCode}");
      }
    } catch (e) {
      // Handle any exceptions that occur during the request
      throw Exception("Request failed: $e");
    }
  }

  // Upload file to a designated S3 bucket using the pre-signed URL
  Future<void> uploadFileToS3(
    String uploadUrl,
    File file,
    String contentType,
  ) async {
    // Read the file contents as bytes
    final fileBytes = await file.readAsBytes();

    // Send a PUT request to the pre-signed URL with the file bytes
    final response = await http.put(
      Uri.parse(uploadUrl),
      headers: {'Content-Type': contentType},
      body: fileBytes,
    );

    // If response failed, throw exception
    if (response.statusCode != 200) {
      // If response is not successful, throw an error with status code and body
      throw ('Upload failed: ${response.statusCode} ${response.body}');
    }
  }

  // Same method as above but with web support for testing (this is temporary and may be removed later)
  Future<void> uploadFileToS3Web(
    String uploadUrl,
    Uint8List fileBytes,
    String contentType,
  ) async {
    // Send a PUT request to the pre-signed URL with the file bytes assigned directly
    final response = await http.put(
      Uri.parse(uploadUrl),
      headers: {'Content-Type': contentType},
      body: fileBytes,
    );

    // If response failed, throw exception
    if (response.statusCode != 200) {
      // If response is not successful, throw an error with status code and body
      throw Exception("Upload failed: ${response.statusCode} ${response.body}");
    }
  }

  // Get the file from S3 and process the contents
  Future<Map<String, dynamic>> processFileFromS3(String fileName) async {
    final url = Uri.parse('$uri/process-file');

    // Headers
    final headers = {'Content-Type': 'application/json'};

    // JSON Payload
    final body = jsonEncode({"file_key": fileName});

    try {
      // Send a POST request to the Flask server to process the file
      final response = await http.post(url, headers: headers, body: body);
      // If successful, parse the JSON response and return the summary
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'summary': data['summary'], 'og_text': data['og_text']};
      } else {
        // If the response is not successful, throw an error with status code
        throw Exception("Server error: ${response.statusCode}");
      }
    } catch (e) {
      // Handle any exceptions that occur during the request
      throw Exception("Failed to process file: $e");
    }
  }
}
