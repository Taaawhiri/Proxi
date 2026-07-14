/// Sender of a chat message: the current user or a peer.
enum MessageSender { me, peer }

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.sender,
    required this.text,
    required this.sentAt,
  });

  final String id;
  final MessageSender sender;
  final String text;
  final DateTime sentAt;
}
