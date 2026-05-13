import 'package:flutter/material.dart';
import '../database/database_provider.dart';
import '../models/chat.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  late Future<List<ChatInfo>> _chatsFuture;

  @override
  void initState() {
    super.initState();
    _loadChats();
  }

  void _loadChats() {
    _chatsFuture = DatabaseProvider.getChats();
  }

  Future<void> _refresh() async {
    setState(() {
      _loadChats();
    });
    await _chatsFuture;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ChatInfo>>(
      future: _chatsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Ошибка: ${snapshot.error}'));
        }

        final chats = snapshot.data ?? [];
        if (chats.isEmpty) {
          return const Center(
            child: Text(
              'Нет чатов. Откройте контакт, чтобы \nначать новый диалог.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _refresh,
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              final updated = chat.updatedAt;
              final subtitle = chat.lastMessage.isNotEmpty ? chat.lastMessage : 'Новый чат';

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  leading: CircleAvatar(
                    radius: 28,
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(chat.avatar, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  title: Text(chat.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13),
                  ),
                  trailing: Text(
                    'час \n${updated.hour.toString().padLeft(2, '0')}:${updated.minute.toString().padLeft(2, '0')}',
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  onTap: () async {
                    await Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => ChatScreen(chat: chat),
                    ));
                    _refresh();
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }
}
