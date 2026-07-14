import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/domain/app_user.dart';
import '../data/mock_chat_repository.dart';
import '../domain/chat_message.dart';
import '../domain/conversation.dart';

final chatRepositoryProvider = Provider((ref) => MockChatRepository());

final chatControllerProvider = StateNotifierProvider<ChatController, ChatState>((ref) {
  return ChatController(ref.watch(chatRepositoryProvider));
});

class ChatState {
  const ChatState({required this.conversations, this.typingPeerIds = const {}});

  final Map<String, Conversation> conversations;
  final Set<String> typingPeerIds;

  ChatState copyWith({Map<String, Conversation>? conversations, Set<String>? typingPeerIds}) {
    return ChatState(
      conversations: conversations ?? this.conversations,
      typingPeerIds: typingPeerIds ?? this.typingPeerIds,
    );
  }
}

class ChatController extends StateNotifier<ChatState> {
  ChatController(this._repository) : super(ChatState(conversations: _repository.seedConversations()));

  final MockChatRepository _repository;
  bool _disposed = false;

  List<Conversation> get conversationsSorted {
    final conversations = state.conversations.values.toList();
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
    return state.conversations[peer.id] ?? Conversation(peer: peer, messages: const []);
  }

  bool isTyping(String peerId) => state.typingPeerIds.contains(peerId);

  void sendMessage(AppUser peer, String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final existing = state.conversations[peer.id] ?? Conversation(peer: peer, messages: const []);
    final myMessage = ChatMessage(
      id: 'msg-${DateTime.now().microsecondsSinceEpoch}',
      sender: MessageSender.me,
      text: trimmed,
      sentAt: DateTime.now(),
    );
    state = state.copyWith(
      conversations: {
        ...state.conversations,
        peer.id: Conversation(peer: peer, messages: [...existing.messages, myMessage]),
      },
      typingPeerIds: {...state.typingPeerIds, peer.id},
    );

    Timer(const Duration(milliseconds: 1800), () => _sendAutoReply(peer));
  }

  void _sendAutoReply(AppUser peer) {
    if (_disposed) return;
    final existing = state.conversations[peer.id];
    if (existing == null) return;

    final reply = ChatMessage(
      id: 'reply-${DateTime.now().microsecondsSinceEpoch}',
      sender: MessageSender.peer,
      text: _repository.nextReply(),
      sentAt: DateTime.now(),
    );
    final typing = {...state.typingPeerIds}..remove(peer.id);
    state = state.copyWith(
      conversations: {
        ...state.conversations,
        peer.id: Conversation(peer: peer, messages: [...existing.messages, reply]),
      },
      typingPeerIds: typing,
    );
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
