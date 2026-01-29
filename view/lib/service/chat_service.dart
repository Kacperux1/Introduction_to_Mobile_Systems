import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:stomp_dart_client/stomp_dart_client.dart';
import '../models/chat_message.dart';

class ChatService {
  static const String _baseUrl = 'https://mobilki.bieda.it';
  static const String _wsUrl = 'ws://mobilki.bieda.it/chat-socket/websocket';

  StompClient? _stompClient;

  void connect({
    required String token,
    required int currentUserId,
    required Function(ChatMessage) onMessageReceived,
  }) {
    _stompClient = StompClient(
      config: StompConfig(
        url: _wsUrl,
        onConnect: (StompFrame frame) {
          _stompClient?.subscribe(
            destination: '/topic/messages/$currentUserId',
            callback: (frame) {
              if (frame.body != null) {
                final Map<String, dynamic> data = jsonDecode(frame.body!);
                onMessageReceived(ChatMessage.fromJson(data));
              }
            },
          );
        },
        onWebSocketError: (dynamic error) => print('WebSocket Error: $error'),
        stompConnectHeaders: {'Authorization': 'Bearer $token'},
        webSocketConnectHeaders: {'Authorization': 'Bearer $token'},
      ),
    );
    _stompClient?.activate();
  }

  void sendMessage(int receiverId, String content) {
    if (_stompClient != null && _stompClient!.connected) {
      // destination should match @MessageMapping in Spring Controller
      _stompClient!.send(
        destination: '/api/chat-socket',
        body: jsonEncode({
          'receiverId': receiverId,
          'content': content,
        }),
      );
    }
  }

  Future<List<ChatMessage>> getChatHistory(int secondUserId, String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/messages?secondUserId=$secondUserId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => ChatMessage.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load chat history');
    }
  }

  void disconnect() {
    _stompClient?.deactivate();
  }
}
