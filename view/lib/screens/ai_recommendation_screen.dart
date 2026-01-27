import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import '../service/ai_chat_service.dart';
import 'book_details_screen.dart';
import '../l10n_helper.dart';
import '../main.dart';

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

  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_messages.isEmpty) {
      final s = S.of(context);
      final initialMessage = s.get('ai_initial_message');
      _messages.add(ChatMessage(
        role: 'assistant',
        content: initialMessage,
      ));
      ThemeSettings.of(context)?.speak(initialMessage);
    }
  }

  void _listen() async {
    if (!_isListening) {
      var status = await Permission.microphone.request();
      if (status.isGranted) {
        bool available = await _speech.initialize(
          onStatus: (val) => debugPrint('onStatus: $val'),
          onError: (val) => debugPrint('onError: $val'),
        );
        if (available) {
          setState(() => _isListening = true);
          final s = S.of(context);
          _speech.listen(
            localeId: s.locale.languageCode == 'pl' ? 'pl_PL' : 'en_US',
            onResult: (val) => setState(() {
              _controller.text = val.recognizedWords;
              if (val.hasConfidenceRating && val.confidence > 0) {
                // Optional: handle end of speech
              }
            }),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Microphone permission denied')),
          );
        }
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    final userMessage = ChatMessage(role: 'user', content: _controller.text);
    setState(() {
      _messages.add(userMessage);
      _isLoading = true;
      _isListening = false;
    });
    _controller.clear();
    _speech.stop();

    final response = await _chatService.sendMessage(_messages, widget.authToken);

    setState(() {
      _messages.add(ChatMessage(role: 'assistant', content: response));
      _isLoading = false;
    });

    if (mounted) {
      final cleanResponse = response.replaceAll(RegExp(r'\[BUY:\d+\]'), '').trim();
      ThemeSettings.of(context)?.speak(cleanResponse);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isHighContrast = theme.scaffoldBackgroundColor == const Color(0xFF301934);
    final isDarkMode = theme.scaffoldBackgroundColor == Colors.black;
    final isDefaultMode = theme.scaffoldBackgroundColor == const Color(0xFF00008B);
    final s = S.of(context);

    Color inputTextColor = (isDarkMode || isDefaultMode) ? Colors.white : (isHighContrast ? Colors.yellow : Colors.black);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(s.get('ai_assistant_title'), style: TextStyle(color: theme.appBarTheme.foregroundColor)),
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
                return _buildMessageBubble(msg, theme, s);
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
                    label: s.get('write_to_ai'),
                    child: TextField(
                      controller: _controller,
                      style: TextStyle(color: inputTextColor),
                      decoration: InputDecoration(
                        hintText: s.get('ai_hint'),
                        hintStyle: TextStyle(color: inputTextColor.withOpacity(0.7)),
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
                        suffixIcon: IconButton(
                          icon: Icon(_isListening ? Icons.mic : Icons.mic_none, 
                               color: _isListening ? Colors.red : inputTextColor.withOpacity(0.7)),
                          onPressed: _listen,
                          tooltip: s.get('voice_input'),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Semantics(
                  button: true,
                  label: s.get('send_message'),
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

  Widget _buildMessageBubble(ChatMessage msg, ThemeData theme, S s) {
    final isUser = msg.role == 'user';
    final isHighContrast = theme.scaffoldBackgroundColor == const Color(0xFF301934);
    final isDefaultMode = theme.scaffoldBackgroundColor == const Color(0xFF00008B);
    final isDarkMode = theme.scaffoldBackgroundColor == Colors.black;

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
          label: '${isUser ? s.get('user_label') : s.get('ai_label')}: $cleanContent',
          child: Align(
            alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
            child: InkWell(
              onTap: () => ThemeSettings.of(context)?.speak(cleanContent),
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
          ),
        ),
        if (match != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Semantics(
              button: true,
              label: s.get('view_recommended_offer'),
              child: Align(
                alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
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
                  label: Text(s.get('view_offer'), style: TextStyle(color: isHighContrast ? Colors.yellow : Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isHighContrast ? Colors.black : Colors.green,
                    side: isHighContrast ? const BorderSide(color: Colors.yellow, width: 2) : BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
