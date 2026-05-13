import 'package:flutter/material.dart';
import '../database/database_provider.dart';
import '../models/user.dart';
import 'chat_screen.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  late Future<List<UserProfile>> _contactsFuture;

  @override
  void initState() {
    super.initState();
    _contactsFuture = DatabaseProvider.getContacts();
  }

  Future<void> _openChat(UserProfile contact) async {
    final navigator = Navigator.of(context);
    final existingChat = await DatabaseProvider.getChatByContact(contact.id);
    final chat = existingChat ?? await DatabaseProvider.createChat(contact.id, contact.name, contact.avatar);
    await navigator.push(MaterialPageRoute(builder: (context) => ChatScreen(chat: chat)));
    if (!mounted) return;
    setState(() {
      _contactsFuture = DatabaseProvider.getContacts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<UserProfile>>(
      future: _contactsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Ошибка: ${snapshot.error}'));
        }

        final contacts = snapshot.data ?? [];
        if (contacts.isEmpty) {
          return const Center(child: Text('Нет контактов'));
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
          itemCount: contacts.length,
          itemBuilder: (context, index) {
            final user = contacts[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                leading: CircleAvatar(
                  radius: 28,
                  backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                  foregroundColor: Theme.of(context).colorScheme.secondary,
                  child: Text(user.avatar, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(
                  user.status,
                  style: const TextStyle(fontSize: 13),
                ),
                trailing: Icon(Icons.message, color: Theme.of(context).colorScheme.primary),
                onTap: () => _openChat(user),
              ),
            );
          },
        );
      },
    );
  }
}
