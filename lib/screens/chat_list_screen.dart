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
          return const Center(child: Text('Нет чатов. Откройте контакт, чтобы начать новый диалог.'));
        }

        return RefreshIndicator(
          onRefresh: _refresh,
          child: ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              final updated = chat.updatedAt;
              final subtitle = chat.lastMessage.isNotEmpty ? chat.lastMessage : 'Новый чат';

              return ListTile(
                leading: CircleAvatar(child: Text(chat.avatar)),
                title: Text(chat.title),
                subtitle: Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
                trailing: Text(
                  '${updated.hour.toString().padLeft(2, '0')}:${updated.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(fontSize: 12),
                ),
                onTap: () async {
                  await Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ChatScreen(chat: chat),
                  ));
                  _refresh();
                },
              );
            },
          ),
        );
      },
    );
  }
}
