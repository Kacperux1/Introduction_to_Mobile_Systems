import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'chat_screen.dart';
import '../l10n_helper.dart';

class ChatListScreen extends StatefulWidget {
  final String authToken;
  final int currentUserId;

  const ChatListScreen({
    super.key,
    required this.authToken,
    required this.currentUserId,
  });

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  late Future<List<ChatPreview>> _chatsFuture;

  @override
  void initState() {
    super.initState();
    _chatsFuture = _fetchChats();
  }

  Future<List<ChatPreview>> _fetchChats() async {
    // This assumes an endpoint that returns a list of users the current user has chatted with
    // For now, we'll implement a workaround if the endpoint doesn't exist, 
    // or we can fetch all messages and group them.
    // Let's assume we have an endpoint /api/messages/users
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8080/api/messages/users'),
      headers: {'Authorization': 'Bearer ${widget.authToken}'},
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => ChatPreview.fromJson(json)).toList();
    } else {
      // Fallback: If the endpoint is not there, we'll return an empty list for now
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(s.get('chats') ?? 'Chats'),
        backgroundColor: theme.appBarTheme.backgroundColor,
      ),
      body: FutureBuilder<List<ChatPreview>>(
        future: _chatsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text(s.get('no_chats') ?? 'No active chats'));
          }

          final chats = snapshot.data!;
          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              return ListTile(
                leading: CircleAvatar(
                  child: Text(chat.userName[0].toUpperCase()),
                ),
                title: Text(chat.userName),
                subtitle: Text(chat.lastMessage),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        receiverId: chat.userId,
                        receiverName: chat.userName,
                        authToken: widget.authToken,
                        currentUserId: widget.currentUserId,
                      ),
                    ),
                  ).then((_) => setState(() { _chatsFuture = _fetchChats(); }));
                },
              );
            },
          );
        },
      ),
    );
  }
}

class ChatPreview {
  final int userId;
  final String userName;
  final String lastMessage;

  ChatPreview({required this.userId, required this.userName, required this.lastMessage});

  factory ChatPreview.fromJson(Map<String, dynamic> json) {
    return ChatPreview(
      userId: json['id'],
      userName: json['login'],
      lastMessage: json['lastMessage'] ?? '',
    );
  }
}
