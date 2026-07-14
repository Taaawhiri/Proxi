import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/domain/app_user.dart';
import '../data/mock_chat_repository.dart';
import '../domain/chat_message.dart';
import '../domain/conversation.dart';

final chatRepositoryProvider = Provider((ref) => MockChatRepository());

final chatControllerProvider =
    StateNotifierProvider<ChatController, Map<String, Conversation>>((ref) {
  return ChatController(ref.watch(chatRepositoryProvider));
});

class ChatController extends StateNotifier<Map<String, Conversation>> {
  ChatController(this._repository) : super(_repository.seedConversations());

  final MockChatRepository _repository;
  bool _disposed = false;

  List<Conversation> get conversationsSorted {
    final conversations = state.values.toList();
    conversations.sort((a, b) {
      final aTime = a.lastMessage?.sentAt;
      final bTime = b.lastMessage?.sentAt;
      if (aTime == null) return 1;
      if (bTime == null) return -1;
      return bTime.compareTo(aTime);
    });
    return conversations;
  }

  Conversation conversationWith(AppUser peer) {
    return state[peer.id] ?? Conversation(peer: peer, messages: const []);
  }

  void sendMessage(AppUser peer, String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final existing = state[peer.id] ?? Conversation(peer: peer, messages: const []);
    final myMessage = ChatMessage(
      id: 'msg-${DateTime.now().microsecondsSinceEpoch}',
      sender: MessageSender.me,
      text: trimmed,
      sentAt: DateTime.now(),
    );
    state = {
      ...state,
      peer.id: Conversation(peer: peer, messages: [...existing.messages, myMessage]),
    };

    Timer(const Duration(milliseconds: 1400), () => _sendAutoReply(peer));
  }

  void _sendAutoReply(AppUser peer) {
    if (_disposed) return;
    final existing = state[peer.id];
    if (existing == null) return;

    final reply = ChatMessage(
      id: 'reply-${DateTime.now().microsecondsSinceEpoch}',
      sender: MessageSender.peer,
      text: _repository.nextReply(),
      sentAt: DateTime.now(),
    );
    state = {
      ...state,
      peer.id: Conversation(peer: peer, messages: [...existing.messages, reply]),
    };
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
