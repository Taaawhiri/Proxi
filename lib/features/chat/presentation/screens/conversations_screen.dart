import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/chat_message.dart';
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
              separatorBuilder: (context, index) => const Divider(height: 1, indent: 76),
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
    final hasUnread = lastMessage != null && lastMessage.sender == MessageSender.peer;

    return OpenContainer(
      transitionType: ContainerTransitionType.fade,
      transitionDuration: const Duration(milliseconds: 400),
      closedElevation: 0,
      closedColor: Theme.of(context).scaffoldBackgroundColor,
      openColor: Theme.of(context).scaffoldBackgroundColor,
      closedBuilder: (context, openContainer) => ListTile(
        onTap: openContainer,
        leading: Hero(
          tag: 'chat-avatar-${conversation.peer.id}',
          child: CircleAvatar(child: Text(conversation.peer.initials)),
        ),
        title: Text(conversation.peer.name),
        subtitle: lastMessage == null
            ? null
            : Text(
                lastMessage.text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: hasUnread ? const TextStyle(fontWeight: FontWeight.w600) : null,
              ),
        trailing: lastMessage == null
            ? null
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(DateFormat.Hm().format(lastMessage.sentAt)),
                  if (hasUnread) ...[
                    const SizedBox(height: 4),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
      ),
      openBuilder: (context, closeContainer) => ChatDetailScreen(peer: conversation.peer),
    );
  }
}
