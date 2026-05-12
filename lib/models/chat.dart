class ChatInfo {
  final int id;
  final int contactId;
  final String title;
  final String avatar;
  final String lastMessage;
  final DateTime updatedAt;

  const ChatInfo({
    required this.id,
    required this.contactId,
    required this.title,
    required this.avatar,
    required this.lastMessage,
    required this.updatedAt,
  });

  factory ChatInfo.fromMap(Map<String, dynamic> map) {
    return ChatInfo(
      id: map['id'] as int,
      contactId: map['contactId'] as int,
      title: map['title'] as String,
      avatar: map['avatar'] as String,
      lastMessage: map['lastMessage'] as String,
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'contactId': contactId,
      'title': title,
      'avatar': avatar,
      'lastMessage': lastMessage,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }
}
