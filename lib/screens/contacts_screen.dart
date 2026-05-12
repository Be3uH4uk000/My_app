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
        return ListView.separated(
          itemCount: contacts.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final user = contacts[index];
            return ListTile(
              leading: CircleAvatar(child: Text(user.avatar)),
              title: Text(user.name),
              subtitle: Text(user.status),
              onTap: () => _openChat(user),
            );
          },
        );
      },
    );
  }
}
