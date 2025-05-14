import 'dart:convert';
import 'package:http/http.dart' as http;

/*

Service class to handle Llama API

*/

class LlamaApiService {
  // Get the previous user and assistant responses
  late List<String> previousUserMessages = [];
  late List<String> previousAssistantMessages = [];

  Future<String> sendMessageToFlask(
    List<Map<String, String>> context,
    String userMessage,
  ) async {
    final url = Uri.parse(
      'http://10.0.2.2:5001/safe_chat', // Flask Url (Android IP: 10.0.2.2 - Web IP: localhost or 127.0.0.0)
    );

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

  // TODO: Fix streamMessageFromFlask
  Stream<String> streamMessageFromFlask(List<Map<String, String>> context, String message) async* {
  final url = Uri.parse('http://10.0.2.2:5001/stream_chat'); // Adjust as needed
  final body = {
    'context': context,
    'message': message,
  };

  final request = 
    http.Request('POST', url)
      ..headers['Content-Type'] = 'application/json'
      ..body = jsonEncode(body);

  final response = await request.send();

  final stream = response.stream.transform(utf8.decoder);

  await for (var chunk in stream) {
    // Print raw chunk for debugging
    print('Raw chunk: $chunk');

    // Handle if chunk is like "data: { ... }"
    final cleaned = chunk.replaceFirst(RegExp(r'^data:\s*'), '').trim();

    // Skip if it's just 'data: [DONE]' or similar
    if (cleaned.toLowerCase().contains('[done]')) continue;

    try {
      final jsonData = json.decode(cleaned);
      final content = jsonData['message']?['content'];
      if (content != null && content is String) {
        yield content;
      }
    } catch (e) {
      print('JSON parse error: $e\nChunk: $cleaned');
    }
  }
}
}
