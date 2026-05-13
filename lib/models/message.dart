enum MessageType { text, audio, video }

class ChatMessage {
  final int id;
  final int chatId;
  final String text;
  final DateTime timestamp;
  final bool isMine;
  final MessageType type;
  final String? mediaPath;
  final String? fileName;

  const ChatMessage({
    required this.id,
    required this.chatId,
    required this.text,
    required this.timestamp,
    required this.isMine,
    required this.type,
    this.mediaPath,
    this.fileName,
  });

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    final typeString = map['type'] as String?;
    return ChatMessage(
      id: map['id'] as int,
      chatId: map['chatId'] as int,
      text: map['text'] as String,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
      isMine: map['isMine'] == 1,
      type: MessageType.values.firstWhere(
        (value) => value.name == typeString,
        orElse: () => MessageType.text,
      ),
      mediaPath: map['mediaPath'] as String?,
      fileName: map['fileName'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'chatId': chatId,
      'text': text,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'isMine': isMine ? 1 : 0,
      'type': type.name,
      'mediaPath': mediaPath,
      'fileName': fileName,
    };
  }

  String get displayText {
    if (type == MessageType.audio) {
      return fileName != null && fileName!.isNotEmpty ? fileName! : '[Аудио]';
    }
    if (type == MessageType.video) {
      return fileName != null && fileName!.isNotEmpty ? fileName! : '[Видео]';
    }
    return text;
  }
}
