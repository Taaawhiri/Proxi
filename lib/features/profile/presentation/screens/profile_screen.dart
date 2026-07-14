import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/domain/auth_state.dart';
import '../../../auth/presentation/auth_controller.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    if (authState is! Authenticated) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final user = authState.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profilo'),
        actions: [
          IconButton(
            key: const Key('logoutButton'),
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
            icon: const Icon(Icons.logout),
            tooltip: 'Esci',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: CircleAvatar(
              radius: 48,
              child: Text(user.initials, style: const TextStyle(fontSize: 28)),
            ),
          ),
          const SizedBox(height: 16),
          Center(child: Text(user.name, style: Theme.of(context).textTheme.headlineSmall)),
          Center(child: Text(user.email, style: Theme.of(context).textTheme.bodyMedium)),
          const SizedBox(height: 24),
          Text('Bio', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(user.bio.isEmpty ? 'Aggiungi una breve descrizione di te.' : user.bio),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => _editBio(context, ref, user.bio),
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Modifica bio'),
          ),
        ],
      ),
    );
  }

  Future<void> _editBio(BuildContext context, WidgetRef ref, String currentBio) async {
    final controller = TextEditingController(text: currentBio);
    final newBio = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifica bio'),
        content: TextField(controller: controller, maxLines: 3, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Annulla')),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Salva'),
          ),
        ],
      ),
    );
    if (newBio != null) {
      await ref.read(authControllerProvider.notifier).updateBio(newBio.trim());
    }
  }
}
