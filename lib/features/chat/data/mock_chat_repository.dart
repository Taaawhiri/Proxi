import '../../auth/domain/app_user.dart';
import '../domain/chat_message.dart';
import '../domain/conversation.dart';

/// Seed data for a couple of demo conversations, and canned auto-replies
/// used to simulate a peer answering. Replace with a real chat backend
/// (e.g. WebSocket) once available.
class MockChatRepository {
  static final _repliesPool = [
    'Ciao! Anche io sono da queste parti 👋',
    'Fico, ci vediamo in zona?',
    'Sto prendendo un caffè qui vicino, tu?',
    'Perfetto, a dopo!',
  ];

  int _replyIndex = 0;

  String nextReply() {
    final reply = _repliesPool[_replyIndex % _repliesPool.length];
    _replyIndex++;
    return reply;
  }

  Map<String, Conversation> seedConversations() {
    final now = DateTime.now();
    final giulia = AppUser(id: 'demo-0', name: 'Giulia', email: 'giulia@example.com');
    final marco = AppUser(id: 'demo-1', name: 'Marco', email: 'marco@example.com');

    return {
      giulia.id: Conversation(
        peer: giulia,
        messages: [
          ChatMessage(
            id: 'seed-1',
            sender: MessageSender.peer,
            text: 'Ciao! Ho visto che sei nelle vicinanze 😊',
            sentAt: now.subtract(const Duration(minutes: 12)),
          ),
          ChatMessage(
            id: 'seed-2',
            sender: MessageSender.me,
            text: 'Ciao Giulia! Sì, sono qui vicino alla stazione.',
            sentAt: now.subtract(const Duration(minutes: 10)),
          ),
        ],
      ),
      marco.id: Conversation(
        peer: marco,
        messages: [
          ChatMessage(
            id: 'seed-3',
            sender: MessageSender.peer,
            text: 'Ehi, ci va di prendere un aperitivo?',
            sentAt: now.subtract(const Duration(hours: 2)),
          ),
        ],
      ),
    };
  }
}
