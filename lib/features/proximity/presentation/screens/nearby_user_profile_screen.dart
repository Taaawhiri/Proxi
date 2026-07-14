import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../chat/presentation/chat_controller.dart';
import '../../../chat/presentation/screens/chat_detail_screen.dart';
import '../../domain/nearby_user.dart';
import '../user_relations_controller.dart';

/// Full-screen profile for a nearby user, with all the ways to interact
/// with them beyond the classic "send message".
class NearbyUserProfileScreen extends ConsumerWidget {
  const NearbyUserProfileScreen({super.key, required this.user});

  final NearbyUser user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final relations = ref.watch(userRelationsControllerProvider);
    final isFavorite = relations.favoriteIds.contains(user.profile.id);

    return Scaffold(
      appBar: AppBar(
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(context, ref, value),
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'block', child: Text('Blocca utente')),
              PopupMenuItem(value: 'report', child: Text('Segnala utente')),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: CircleAvatar(
              radius: 56,
              backgroundColor: user.isOnline
                  ? Theme.of(context).colorScheme.secondary
                  : Colors.grey,
              child: Text(user.profile.initials, style: const TextStyle(fontSize: 32, color: Colors.white)),
            ),
          ),
          const SizedBox(height: 16),
          Center(child: Text(user.profile.name, style: Theme.of(context).textTheme.headlineSmall)),
          Center(
            child: Text(
              '${user.isOnline ? "Online" : "Offline"} · A ${user.formattedDistance} da te',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: 24),
          if (user.profile.bio.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(user.profile.bio),
              ),
            ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (context) => ChatDetailScreen(peer: user.profile)),
                  ),
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: const Text('Messaggio'),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: () => _sendWave(context, ref),
                icon: const Text('👋'),
                label: const Text('Saluta'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => ref.read(userRelationsControllerProvider.notifier).toggleFavorite(user.profile.id),
            icon: Icon(isFavorite ? Icons.star : Icons.star_border, color: isFavorite ? Colors.amber : null),
            label: Text(isFavorite ? 'Nei preferiti' : 'Aggiungi ai preferiti'),
          ),
        ],
      ),
    );
  }

  void _sendWave(BuildContext context, WidgetRef ref) {
    ref.read(chatControllerProvider.notifier).sendMessage(user.profile, '👋');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Hai salutato ${user.profile.name}!')),
    );
  }

  void _handleMenuAction(BuildContext context, WidgetRef ref, String action) {
    switch (action) {
      case 'block':
        _confirmBlock(context, ref);
      case 'report':
        _showReportDialog(context);
    }
  }

  Future<void> _confirmBlock(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bloccare questo utente?'),
        content: Text('${user.profile.name} non comparirà più nelle vicinanze e non potrà scriverti.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Annulla')),
          FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Blocca')),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await ref.read(userRelationsControllerProvider.notifier).block(user.profile.id);
      if (context.mounted) Navigator.of(context).pop();
    }
  }

  Future<void> _showReportDialog(BuildContext context) async {
    const reasons = ['Comportamento inappropriato', 'Profilo falso', 'Spam', 'Altro'];
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Segnala utente'),
        children: [
          for (final reason in reasons)
            SimpleDialogOption(
              onPressed: () => Navigator.of(context).pop(reason),
              child: Text(reason),
            ),
        ],
      ),
    );
    if (reason != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Grazie, la segnalazione è stata inviata.')),
      );
    }
  }
}
