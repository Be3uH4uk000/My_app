class ChatMessage {
  final int id;
  final int chatId;
  final String text;
  final DateTime timestamp;
  final bool isMine;

  const ChatMessage({
    required this.id,
    required this.chatId,
    required this.text,
    required this.timestamp,
    required this.isMine,
  });

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'] as int,
      chatId: map['chatId'] as int,
      text: map['text'] as String,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
      isMine: map['isMine'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'chatId': chatId,
      'text': text,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'isMine': isMine ? 1 : 0,
    };
  }
}
