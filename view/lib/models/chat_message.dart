class ChatMessage {
  final int? id;
  final int? senderId;
  final int receiverId;
  final String content;
  final DateTime sent;

  ChatMessage({
    this.id,
    this.senderId,
    required this.receiverId,
    required this.content,
    required this.sent,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      senderId: json['senderId'],
      receiverId: json['receiverId'],
      content: json['content'],
      sent: json['sent'] != null ? DateTime.parse(json['sent']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'sent': sent.toIso8601String(),
    };
  }
}
