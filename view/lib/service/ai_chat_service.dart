import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatMessage {
  final String role;
  final String content;

  ChatMessage({required this.role, required this.content});

  Map<String, dynamic> toJson() => {
    'role': role,
    'content': content,
  };
}

class AiChatService {
  // Zmień na IP swojego serwera, jeśli testujesz na fizycznym urządzeniu
  static const String baseUrl = 'http://10.0.2.2:8080/api/external';

  Future<String> sendMessage(List<ChatMessage> history, String? authToken) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chat'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode(history.map((m) => m.toJson()).toList()),
      );

      if (response.statusCode == 200) {
        // Jeśli backend zwraca surowy String, nie musimy go dekodować z JSON (chyba że to JSON String)
        return response.body;
      } else {
        return 'Błąd serwera: ${response.statusCode}';
      }
    } catch (e) {
      return 'Błąd połączenia: $e';
    }
  }
}
