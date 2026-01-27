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
      );

      if (response.statusCode == 200) {
        return response.body;
      } else {
        return 'Błąd serwera: ${response.statusCode}';
      }
    } catch (e) {
      return 'Błąd połączenia: $e';
    }
  }

  Future<String> translateTitle(String title, String targetLanguage, String? authToken) async {
    final cacheKey = '$title-$targetLanguage';
    if (_translationCache.containsKey(cacheKey)) {
      final cachedMap = _translationCache[cacheKey];
      if (cachedMap != null && cachedMap.containsKey(targetLanguage)) {
        return cachedMap[targetLanguage]!;
      }
    }

    try {
      String promptContent;
      if (targetLanguage == 'pl') {
        promptContent = 'Translate the following book title to Polish. IMPORTANT: If the title is already in English, do NOT translate it—return it exactly as it is. Return ONLY the title text: "$title"';
      } else {
        promptContent = 'Translate the following book title to English. Return ONLY the translated title text: "$title"';
      }

      final prompt = [
        ChatMessage(
          role: 'user', 
          content: promptContent
        )
      ];

      final response = await sendMessage(prompt, authToken);
      
      // Basic cleanup if AI adds quotes or extra spaces
      final translated = response.replaceAll('"', '').trim();
      
      if (!_translationCache.containsKey(cacheKey)) {
        _translationCache[cacheKey] = {};
      }
      _translationCache[cacheKey]![targetLanguage] = translated;

      return translated;
    } catch (e) {
      return title; // Fallback to original
    }
  }
}
