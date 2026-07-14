import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/conversation.dart';
import '../chat_controller.dart';
import 'chat_detail_screen.dart';

class ConversationsScreen extends ConsumerWidget {
  const ConversationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(chatControllerProvider);
    final conversations = ref.read(chatControllerProvider.notifier).conversationsSorted;

    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: conversations.isEmpty
          ? const Center(child: Text('Nessuna conversazione ancora.'))
          : ListView.separated(
              itemCount: conversations.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) => _ConversationTile(conversation: conversations[index]),
            ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({required this.conversation});

  final Conversation conversation;

  @override
  Widget build(BuildContext context) {
    final lastMessage = conversation.lastMessage;

    return ListTile(
      leading: CircleAvatar(child: Text(conversation.peer.initials)),
      title: Text(conversation.peer.name),
      subtitle: lastMessage == null
          ? null
          : Text(lastMessage.text, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: lastMessage == null ? null : Text(DateFormat.Hm().format(lastMessage.sentAt)),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => ChatDetailScreen(peer: conversation.peer),
        ),
      ),
    );
  }
}
