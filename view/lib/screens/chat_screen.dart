import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/chat_message.dart';
import '../service/chat_service.dart';
import '../l10n_helper.dart';

class ChatScreen extends StatefulWidget {
  final int receiverId;
  final String receiverName;
  final String authToken;
  final int currentUserId;

  const ChatScreen({
    super.key,
    required this.receiverId,
    required this.receiverName,
    required this.authToken,
    required this.currentUserId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ChatService _chatService = ChatService();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadHistory();
    _chatService.connect(
      token: widget.authToken,
      currentUserId: widget.currentUserId,
      onMessageReceived: (message) {
        if (mounted) {
          // Check if the message belongs to this conversation
          bool isRelevant = (message.senderId == widget.receiverId && message.receiverId == widget.currentUserId) ||
                            (message.senderId == widget.currentUserId && message.receiverId == widget.receiverId);
          
          if (isRelevant) {
            setState(() {
              _messages.add(message);
            });
            _scrollToBottom();
          }
        }
      },
    );
  }

  Future<void> _loadHistory() async {
    try {
      final history = await _chatService.getChatHistory(widget.receiverId, widget.authToken);
      if (mounted) {
        setState(() {
          _messages.clear();
          _messages.addAll(history);
          _messages.sort((a, b) => a.sent.compareTo(b.sent));
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load chat history: $e')),
        );
      }
    }
  }

  void _sendMessage() {
    if (_controller.text.trim().isNotEmpty) {
      _chatService.sendMessage(widget.receiverId, _controller.text.trim());
      _controller.clear();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.position.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _chatService.disconnect();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);
    final isHighContrast = theme.scaffoldBackgroundColor == const Color(0xFF301934);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.receiverName),
        backgroundColor: theme.appBarTheme.backgroundColor,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                // If I am the sender, the message should be on the right
                final isMe = message.senderId == widget.currentUserId;
                return _buildMessageBubble(message, isMe, theme, isHighContrast);
              },
            ),
          ),
          _buildInputArea(theme, isHighContrast, s),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message, bool isMe, ThemeData theme, bool isHighContrast) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isMe 
            ? (isHighContrast ? Colors.yellow : Colors.blue) 
            : (isHighContrast ? Colors.black : Colors.grey[300]),
          borderRadius: BorderRadius.circular(12),
          border: isHighContrast ? Border.all(color: Colors.yellow) : null,
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message.content,
              style: TextStyle(
                color: isMe 
                  ? (isHighContrast ? Colors.black : Colors.white) 
                  : (isHighContrast ? Colors.yellow : Colors.black),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('HH:mm').format(message.sent),
              style: TextStyle(
                fontSize: 10,
                color: isMe 
                  ? (isHighContrast ? Colors.black54 : Colors.white70) 
                  : (isHighContrast ? Colors.yellow.withOpacity(0.7) : Colors.black54),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea(ThemeData theme, bool isHighContrast, S s) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border(top: BorderSide(color: theme.dividerColor)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              style: TextStyle(color: isHighContrast ? Colors.yellow : null),
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: TextStyle(color: isHighContrast ? Colors.yellow.withOpacity(0.5) : null),
                border: InputBorder.none,
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send, color: isHighContrast ? Colors.yellow : Colors.blue),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}
