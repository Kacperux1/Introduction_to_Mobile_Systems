import 'dart:convert';
import 'package:http/http.dart' as http;
import 'ai_chat_service.dart';

class BookInfoService {
  final AiChatService _aiService = AiChatService();

  /// Fetches a book cover URL with AI-assisted normalization and reliable fallbacks.
  Future<String> getCoverUrl(String title, String author, String? authToken) async {
    // 1. Try direct search first (Google Books)
    String? url = await _fetchFromGoogleBooks('$title $author');
    if (url != null) return url;

    // 2. Try OpenLibrary with title/author
    url = await _fetchFromOpenLibrary(title, author);
    if (url != null) return url;

    // 3. AI Normalization: If still nothing, ask AI for the original title or ISBN
    if (authToken != null) {
      final info = await _normalizeBookInfo(title, author, authToken);
      if (info != null) {
        // Try searching with normalized English title
        url = await _fetchFromGoogleBooks('${info['originalTitle']} $author');
        if (url != null) return url;

        // Try searching by ISBN (most reliable)
        if (info['isbn'] != null) {
          final isbnUrl = 'https://covers.openlibrary.org/b/isbn/${info['isbn']}-L.jpg';
          try {
            final head = await http.head(Uri.parse(isbnUrl)).timeout(const Duration(seconds: 3));
            if (head.statusCode == 200) return isbnUrl;
          } catch (_) {}
        }
      }
    }

    // 4. Ultimate fallback: Reliable aesthetic generic book photo from Unsplash
    // This source is stable and avoids placeholder server issues.
    return 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?q=80&w=500&auto=format&fit=crop';
  }

  Future<Map<String, String?>?> _normalizeBookInfo(String title, String author, String token) async {
    try {
      final prompt = [
        ChatMessage(
          role: 'user',
          content: 'Given the book "$title" by "$author", provide its original English title and ISBN-13. Return ONLY a JSON object like {"originalTitle": "...", "isbn": "..."}. No other text.'
        )
      ];
      final response = await _aiService.sendMessage(prompt, token);
      final data = jsonDecode(response.replaceAll('```json', '').replaceAll('```', '').trim());
      return {
        'originalTitle': data['originalTitle']?.toString(),
        'isbn': data['isbn']?.toString(),
      };
    } catch (_) {
      return null;
    }
  }

  Future<String?> _fetchFromGoogleBooks(String queryText) async {
    try {
      final query = Uri.encodeComponent(queryText);
      final url = Uri.parse('https://www.googleapis.com/books/v1/volumes?q=$query&maxResults=5');
      
      final response = await http.get(url).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['items'] != null) {
          for (var item in data['items']) {
            final volumeInfo = item['volumeInfo'];
            final imageLinks = volumeInfo['imageLinks'];
            if (imageLinks != null) {
              String? thumb = imageLinks['extraLarge'] ?? 
                              imageLinks['large'] ?? 
                              imageLinks['medium'] ?? 
                              imageLinks['thumbnail'];
              if (thumb != null) {
                return thumb.replaceFirst('http://', 'https://').replaceAll('&edge=curl', '').replaceAll('zoom=1', 'zoom=3');
              }
            }
          }
        }
      }
    } catch (_) {}
    return null;
  }

  Future<String?> _fetchFromOpenLibrary(String title, String author) async {
    try {
      final query = Uri.encodeComponent('$title $author');
      final url = Uri.parse('https://openlibrary.org/search.json?q=$query&limit=5');
      
      final response = await http.get(url).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['docs'] != null) {
          for (var doc in data['docs']) {
            if (doc['cover_i'] != null) {
              return 'https://covers.openlibrary.org/b/id/${doc['cover_i']}-L.jpg';
            }
            if (doc['isbn'] != null && (doc['isbn'] as List).isNotEmpty) {
              return 'https://covers.openlibrary.org/b/isbn/${doc['isbn'][0]}-L.jpg';
            }
          }
        }
      }
    } catch (_) {}
    return null;
  }
}
