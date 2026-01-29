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
  static const String baseUrl = 'http://10.0.2.2:8080/api/external';
  
  // Cache for translations to avoid unnecessary API calls
  static final Map<String, Map<String, String>> _translationCache = {};

  Future<String> sendMessage(List<ChatMessage> history, String? authToken) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chat'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode(history.map((m) => m.toJson()).toList()),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return response.body;
      } else {
        return 'ERROR_RESPONSE';
      }
    } catch (e) {
      return 'CONNECTION_ERROR';
    }
  }

  Future<String> translateTitle(String title, String targetLanguage, String? authToken) async {
    final cacheKey = title; // Simplify cache key to title
    if (_translationCache.containsKey(cacheKey) && _translationCache[cacheKey]!.containsKey(targetLanguage)) {
      return _translationCache[cacheKey]![targetLanguage]!;
    }

    try {
      String promptContent;
      if (targetLanguage == 'pl') {
        promptContent = 'Translate this book title to Polish. If it is already in English or Polish, keep it as is. Return ONLY the title text, no quotes: "$title"';
      } else {
        promptContent = 'Translate this book title to English. Return ONLY the title text, no quotes: "$title"';
      }

      final prompt = [
        ChatMessage(
          role: 'user', 
          content: promptContent
        )
      ];

      final response = await sendMessage(prompt, authToken);
      
      // Validation: If it is an error or it is suspiciously long (more than 150 chars or 2x original), ignore it.
      if (response == 'ERROR_RESPONSE' || response == 'CONNECTION_ERROR' || response.length > 150 || response.length > title.length * 3) {
        return title; 
      }

      // Basic cleanup
      final translated = response.replaceAll('"', '').trim();
      
      if (!_translationCache.containsKey(cacheKey)) {
        _translationCache[cacheKey] = {};
      }
      _translationCache[cacheKey]![targetLanguage] = translated;

      return translated;
    } catch (e) {
      return title;
    }
  }
}
