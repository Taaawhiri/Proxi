import '../../auth/domain/app_user.dart';
import 'chat_message.dart';

class Conversation {
  const Conversation({required this.peer, required this.messages});

  final AppUser peer;
  final List<ChatMessage> messages;

  ChatMessage? get lastMessage => messages.isEmpty ? null : messages.last;
}
