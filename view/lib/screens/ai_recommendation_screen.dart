import 'package:flutter/material.dart';
import '../service/ai_chat_service.dart';
import 'book_details_screen.dart';

class AiRecommendationScreen extends StatefulWidget {
  final String? authToken;

  const AiRecommendationScreen({super.key, this.authToken});

  @override
  State<AiRecommendationScreen> createState() => _AiRecommendationScreenState();
}

class _AiRecommendationScreenState extends State<AiRecommendationScreen> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final AiChatService _chatService = AiChatService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _messages.add(ChatMessage(
      role: 'assistant',
      content: 'Cześć! Jestem Twoim asystentem książkowym. Nie masz co czytać? Opowiedz mi o swoich ulubionych gatunkach, a znajdę coś dla Ciebie!',
    ));
  }

  void _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    final userMessage = ChatMessage(role: 'user', content: _controller.text);
    setState(() {
      _messages.add(userMessage);
      _isLoading = true;
    });
    _controller.clear();

    final response = await _chatService.sendMessage(_messages, widget.authToken);

    setState(() {
      _messages.add(ChatMessage(role: 'assistant', content: response));
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isHighContrast = theme.scaffoldBackgroundColor == const Color(0xFF301934);
    final isDarkMode = theme.scaffoldBackgroundColor == Colors.black;
    final isDefaultMode = theme.scaffoldBackgroundColor == const Color(0xFF00008B);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Asystent AI', style: TextStyle(color: theme.appBarTheme.foregroundColor)),
        backgroundColor: theme.appBarTheme.backgroundColor,
        iconTheme: theme.appBarTheme.iconTheme ?? IconThemeData(color: theme.appBarTheme.foregroundColor),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _buildMessageBubble(msg, theme);
              },
            ),
          ),
          if (_isLoading) LinearProgressIndicator(color: isHighContrast ? Colors.yellow : null),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: Semantics(
                    label: 'Write to AI assistant',
                    child: TextField(
                      controller: _controller,
                      style: TextStyle(color: isHighContrast ? Colors.yellow : (isDarkMode || isDefaultMode ? Colors.white : Colors.black)),
                      decoration: InputDecoration(
                        hintText: 'Napisz do AI...',
                        hintStyle: TextStyle(color: isHighContrast ? Colors.yellow.withOpacity(0.7) : (isDarkMode || isDefaultMode ? Colors.white70 : Colors.black54)),
                        filled: true,
                        fillColor: isHighContrast ? Colors.black : (isDarkMode || isDefaultMode ? Colors.white.withOpacity(0.1) : Colors.grey[200]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: isHighContrast ? const BorderSide(color: Colors.yellow, width: 2) : BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: isHighContrast ? const BorderSide(color: Colors.yellow, width: 2) : BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Semantics(
                  button: true,
                  label: 'Send message',
                  child: IconButton(
                    icon: Icon(Icons.send, color: isHighContrast ? Colors.yellow : (isDarkMode || isDefaultMode ? Colors.white : theme.primaryColor)),
                    onPressed: _isLoading ? null : _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg, ThemeData theme) {
    final isUser = msg.role == 'user';
    final isHighContrast = theme.scaffoldBackgroundColor == const Color(0xFF301934);
    final isDefaultMode = theme.scaffoldBackgroundColor == const Color(0xFF00008B);
    final isDarkMode = theme.scaffoldBackgroundColor == Colors.black;

    // Parser dla [BUY:ID]
    final buyRegex = RegExp(r'\[BUY:(\d+)\]');
    final match = buyRegex.firstMatch(msg.content);
    String cleanContent = msg.content.replaceAll(buyRegex, '').trim();

    Color bubbleColor;
    Color textColor;
    if (isHighContrast) {
      bubbleColor = isUser ? Colors.yellow : Colors.black;
      textColor = isUser ? Colors.black : Colors.yellow;
    } else if (isDarkMode || isDefaultMode) {
      bubbleColor = isUser ? Colors.white.withOpacity(0.2) : Colors.white.withOpacity(0.1);
      textColor = Colors.white;
    } else {
      bubbleColor = isUser ? Colors.blue[100]! : Colors.grey[200]!;
      textColor = Colors.black;
    }

    return Column(
      crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Semantics(
          label: '${isUser ? 'You' : 'AI Assistant'}: $cleanContent',
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: BorderRadius.circular(15),
              border: isHighContrast ? Border.all(color: Colors.yellow, width: 2) : null,
            ),
            child: Text(cleanContent, style: TextStyle(color: textColor)),
          ),
        ),
        if (match != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Semantics(
              button: true,
              label: 'View recommended book offer',
              child: ElevatedButton.icon(
                onPressed: () {
                  final bookId = int.parse(match.group(1)!);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookDetailsScreen(
                        bookId: bookId,
                        isLoggedIn: widget.authToken != null,
                      ),
                    ),
                  );
                },
                icon: Icon(Icons.shopping_cart, color: isHighContrast ? Colors.yellow : Colors.white),
                label: Text('Zobacz tę ofertę', style: TextStyle(color: isHighContrast ? Colors.yellow : Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isHighContrast ? Colors.black : Colors.green,
                  side: isHighContrast ? const BorderSide(color: Colors.yellow, width: 2) : BorderSide.none,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
