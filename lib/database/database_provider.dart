import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../models/chat.dart';
import '../models/message.dart';
import '../models/user.dart';

class DatabaseProvider {
  static Database? _usersDb;
  static Database? _chatsDb;
  static Database? _messagesDb;

  static Future<void> init() async {
    final directory = await getApplicationDocumentsDirectory();
    final usersPath = join(directory.path, 'users.db');
    final chatsPath = join(directory.path, 'chats.db');
    final messagesPath = join(directory.path, 'messages.db');

    _usersDb = await openDatabase(usersPath, version: 1, onCreate: _createUsersDb);
    _chatsDb = await openDatabase(chatsPath, version: 1, onCreate: _createChatsDb);
    _messagesDb = await openDatabase(messagesPath, version: 2, onCreate: _createMessagesDb, onUpgrade: _upgradeMessagesDb);

    await _ensureSampleData();
  }

  static Future<void> _createUsersDb(Database db, int version) async {
    await db.execute('''
    CREATE TABLE users(
      id INTEGER PRIMARY KEY,
      name TEXT NOT NULL,
      status TEXT NOT NULL,
      avatar TEXT NOT NULL
    )''');
  }

  static Future<void> _createChatsDb(Database db, int version) async {
    await db.execute('''
    CREATE TABLE chats(
      id INTEGER PRIMARY KEY,
      contactId INTEGER NOT NULL,
      title TEXT NOT NULL,
      avatar TEXT NOT NULL,
      lastMessage TEXT NOT NULL,
      updatedAt INTEGER NOT NULL
    )''');
  }

  static Future<void> _createMessagesDb(Database db, int version) async {
    await db.execute('''
    CREATE TABLE messages(
      id INTEGER PRIMARY KEY,
      chatId INTEGER NOT NULL,
      text TEXT NOT NULL,
      timestamp INTEGER NOT NULL,
      isMine INTEGER NOT NULL,
      type TEXT NOT NULL DEFAULT 'text',
      mediaPath TEXT,
      fileName TEXT
    )''');
  }

  static Future<void> _upgradeMessagesDb(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE messages ADD COLUMN type TEXT NOT NULL DEFAULT "text"');
      await db.execute('ALTER TABLE messages ADD COLUMN mediaPath TEXT');
      await db.execute('ALTER TABLE messages ADD COLUMN fileName TEXT');
    }
  }

  static Future<void> _ensureSampleData() async {
    final existingUsers = Sqflite.firstIntValue(await _usersDb!.rawQuery('SELECT COUNT(*) FROM users')) ?? 0;
    if (existingUsers > 0) {
      return;
    }

    await _usersDb!.insert('users', {
      'id': 1,
      'name': 'Анна',
      'status': 'онлайн',
      'avatar': 'A',
    });
    await _usersDb!.insert('users', {
      'id': 2,
      'name': 'Иван',
      'status': 'был(а) 5 мин назад',
      'avatar': 'И',
    });
    await _usersDb!.insert('users', {
      'id': 3,
      'name': 'Катя',
      'status': 'в сети',
      'avatar': 'К',
    });

    await _chatsDb!.insert('chats', {
      'id': 1,
      'contactId': 1,
      'title': 'Анна',
      'avatar': 'A',
      'lastMessage': 'Привет! Как дела?',
      'updatedAt': DateTime.now().subtract(const Duration(minutes: 2)).millisecondsSinceEpoch,
    });
    await _chatsDb!.insert('chats', {
      'id': 2,
      'contactId': 2,
      'title': 'Иван',
      'avatar': 'И',
      'lastMessage': 'Договорились, увидимся завтра.',
      'updatedAt': DateTime.now().subtract(const Duration(hours: 1)).millisecondsSinceEpoch,
    });

    await _messagesDb!.insert('messages', {
      'id': 1,
      'chatId': 1,
      'text': 'Привет! Как дела?',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 5)).millisecondsSinceEpoch,
      'isMine': 0,
    });
    await _messagesDb!.insert('messages', {
      'id': 2,
      'chatId': 1,
      'text': 'Все отлично, работаю над новым проектом.',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 4)).millisecondsSinceEpoch,
      'isMine': 1,
    });
    await _messagesDb!.insert('messages', {
      'id': 3,
      'chatId': 2,
      'text': 'Договорились, увидимся завтра.',
      'timestamp': DateTime.now().subtract(const Duration(hours: 1)).millisecondsSinceEpoch,
      'isMine': 0,
    });
  }

  static Future<List<UserProfile>> getContacts() async {
    final rows = await _usersDb!.query('users', orderBy: 'name');
    return rows.map((row) => UserProfile.fromMap(row)).toList();
  }

  static Future<UserProfile?> getUserById(int id) async {
    final rows = await _usersDb!.query('users', where: 'id = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return UserProfile.fromMap(rows.first);
  }

  static Future<List<ChatInfo>> getChats() async {
    final rows = await _chatsDb!.query('chats', orderBy: 'updatedAt DESC');
    return rows.map((row) => ChatInfo.fromMap(row)).toList();
  }

  static Future<List<ChatMessage>> getMessages(int chatId) async {
    final rows = await _messagesDb!.query('messages', where: 'chatId = ?', whereArgs: [chatId], orderBy: 'timestamp ASC');
    return rows.map((row) => ChatMessage.fromMap(row)).toList();
  }

  static Future<ChatInfo?> getChatByContact(int contactId) async {
    final rows = await _chatsDb!.query('chats', where: 'contactId = ?', whereArgs: [contactId], limit: 1);
    if (rows.isEmpty) return null;
    return ChatInfo.fromMap(rows.first);
  }

  static Future<ChatInfo> createChat(int contactId, String title, String avatar) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final id = await _chatsDb!.insert('chats', {
      'contactId': contactId,
      'title': title,
      'avatar': avatar,
      'lastMessage': '',
      'updatedAt': now,
    });
    final row = await _chatsDb!.query('chats', where: 'id = ?', whereArgs: [id], limit: 1);
    return ChatInfo.fromMap(row.first);
  }

  static Future<void> sendMessage(
    int chatId,
    String text,
    bool isMine, {
    MessageType type = MessageType.text,
    String? mediaPath,
    String? fileName,
  }) async {
    final now = DateTime.now();
    final lastMessageText = switch (type) {
      MessageType.text => text,
      MessageType.audio => '[Аудио] ${fileName ?? text}',
      MessageType.video => '[Видео] ${fileName ?? text}',
    };

    await _messagesDb!.insert('messages', {
      'chatId': chatId,
      'text': text,
      'timestamp': now.millisecondsSinceEpoch,
      'isMine': isMine ? 1 : 0,
      'type': type.name,
      'mediaPath': mediaPath,
      'fileName': fileName,
    });

    await _chatsDb!.update(
      'chats',
      {
        'lastMessage': lastMessageText,
        'updatedAt': now.millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [chatId],
    );
  }
}
