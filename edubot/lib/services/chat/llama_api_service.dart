import 'dart:convert';
import 'dart:io';
import 'package:edubot/services/authentication/auth_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/*

Service class to handle Llama API

*/

class LlamaApiService {
  // Flask Url (Android IP: 10.0.2.2 - Web IP: localhost or 127.0.0.0)
  final String uri = kIsWeb ? 'http://localhost:5001' : 'http://10.0.2.2:5001';

  // Send a message and recieve the full JSON response
  Future<String> sendMessageToFlask(
    List<Map<String, String>> context,
    String userMessage,
  ) async {
    final url = Uri.parse('$uri/safe_chat');

    // Headers
    final headers = {'Content-Type': 'application/json'};

    // JSON Payload
    final body = jsonEncode({"message": userMessage, "context": context});

    // Try send post request to Flask server
    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['response'];
      } else {
        throw Exception("Server error: ${response.statusCode}");
      }
    } catch (e) {
      // Handle errors
      throw Exception("Request failed: $e");
    }
  }

  // Send a message and recieve each chunk displayed as a list
  Stream<String> streamMessageFromFlask(
    List<Map<String, String>> context,
    String message,
  ) async* {
    final AuthManager authManager = AuthManager();
    final url = Uri.parse(
      '$uri/stream_chat',
    ); // Flask Url (Android IP: 10.0.2.2 - Web IP: localhost or 127.0.0.0)
    final body = {
      'context': context,
      'message': message,
      'displayName': authManager.getCurrentUser()?.displayName,
    };

    final request =
        http.Request('POST', url)
          ..headers['Content-Type'] = 'application/json'
          ..body = jsonEncode(body);

    final response = await request.send();
    final stream = response.stream.transform(utf8.decoder);

    String buffer = '';

    await for (var chunk in stream) {
      buffer += chunk;

      // Split on newlines to process full lines
      final lines = buffer.split('\n');

      // Keep the last line in buffer if it may be incomplete
      buffer = lines.removeLast();

      for (final line in lines) {
        final cleaned = line.replaceFirst(RegExp(r'^data:\s*'), '').trim();

        if (cleaned.toLowerCase().contains('[done]') || cleaned.isEmpty) {
          continue;
        }

        try {
          final jsonData = json.decode(cleaned);
          final content = jsonData['message']?['content'];
          if (content is String) yield content;
        } catch (e) {
          // Don't yield anything broken
          throw Exception('JSON parse error: $e\nLine: $cleaned');
        }
      }
    }

    // Try to process any leftover line
    if (buffer.isNotEmpty) {
      final cleaned = buffer.replaceFirst(RegExp(r'^data:\s*'), '').trim();
      try {
        final jsonData = json.decode(cleaned);
        final content = jsonData['message']?['content'];
        if (content is String) yield content;
      } catch (e) {
        throw Exception('Final JSON parse error: $e\nBuffer: $cleaned');
      }
    }
  }

  // Send a message and recieve a concise summary of the conversation
  Future<String> generateTitleFromFlask(
    List<Map<String, String>> context,
  ) async {
    final url = Uri.parse('$uri/make_title');

    // Headers
    final headers = {'Content-Type': 'application/json'};

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
    
  FILE METHODS 
  
  */

  // Get a pre-signed URL from Flask to recieve S3 URL
  Future<String> getSignedUrlFromFlask(String fileName, String fileType) async {
    final url = Uri.parse('$uri/generate-upload-url');

    // Headers
    final headers = {'Content-Type': 'application/json'};

    // JSON Payload
    final body = jsonEncode({
      "filename": fileName,
      "content_type": fileType,
    }); // CORRECT

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['upload_url'];
      } else {
        throw Exception("Server error: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Request failed: $e");
    }
  }

  // Upload file to an S3 bucket titled 'edubot-document-upload-bucket-<account_id>'
  Future<void> uploadFileToS3(
    String uploadUrl,
    File file,
    String contentType,
  ) async {
    final fileBytes = await file.readAsBytes();
    print(contentType);

    final response = await http.put(
      Uri.parse(uploadUrl),
      headers: {'Content-Type': contentType},
      body: fileBytes,
    );

    if (response.statusCode == 200) {
      print('File uploaded successfully!');
    } else {
      throw ('Upload failed: ${response.statusCode} ${response.body}');
    }
  }

  // Same method as above but with web support for testing (this is temporary and may be removed later)
  Future<void> uploadFileToS3Web(
    String uploadUrl,
    Uint8List fileBytes,
    String contentType,
  ) async {
    final response = await http.put(
      Uri.parse(uploadUrl),
      headers: {'Content-Type': contentType},
      body: fileBytes,
    );

    if (response.statusCode == 200) {
      print("File uploaded successfully (web)!");
    } else {
      throw Exception("Upload failed: ${response.statusCode} ${response.body}");
    }
  }

  // Get the file from S3 and process the contents
  Future<String> processFileFromS3(String fileName) async {
    final url = Uri.parse('$uri/process-docx');
    print(fileName);

    // Headers
    final headers = {'Content-Type': 'application/json'};

    // JSON Payload
    final body = jsonEncode({"file_key": fileName});

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['summary'];
      } else {
        throw Exception("Server error: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Failed to process file: $e");
    }
  }
}
