import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/router/page_transitions.dart';
import '../../../../core/widgets/proxi_avatar.dart';
import '../../../auth/domain/auth_state.dart';
import '../../../auth/presentation/auth_controller.dart';
import '../../../proximity/presentation/proximity_providers.dart';
import '../../../proximity/presentation/screens/nearby_user_profile_screen.dart';
import '../../../proximity/presentation/user_relations_controller.dart';

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
            child: Stack(
              children: [
                ProxiAvatar(initials: user.initials, avatarPath: user.avatarPath, radius: 48),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 2),
                    ),
                    child: IconButton(
                      onPressed: () => _pickAvatar(context, ref),
                      icon: Icon(Icons.camera_alt, color: Theme.of(context).colorScheme.onPrimary, size: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Center(child: Text(user.name, style: Theme.of(context).textTheme.headlineSmall)),
          Center(child: Text(user.email, style: Theme.of(context).textTheme.bodyMedium)),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Bio', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(user.bio.isEmpty ? 'Aggiungi una breve descrizione di te.' : user.bio),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () => _editBio(context, ref, user.bio),
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Modifica bio'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const _FavoritesSection(),
        ],
      ),
    );
  }

  Future<void> _pickAvatar(BuildContext context, WidgetRef ref) async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 800);
    if (picked != null) {
      await ref.read(authControllerProvider.notifier).updateAvatar(picked.path);
    }
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

class _FavoritesSection extends ConsumerWidget {
  const _FavoritesSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoriteIds = ref.watch(userRelationsControllerProvider).favoriteIds;
    final nearbyUsersAsync = ref.watch(nearbyUsersProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('I tuoi preferiti', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            nearbyUsersAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, _) => Text('Errore: $error'),
              data: (users) {
                final favorites = users.where((user) => favoriteIds.contains(user.profile.id)).toList();
                if (favorites.isEmpty) {
                  return const Text('Nessun preferito ancora. Aggiungine uno dalla mappa!');
                }
                return Column(
                  children: [
                    for (final user in favorites)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(child: Text(user.profile.initials)),
                        title: Text(user.profile.name),
                        subtitle: Text('A ${user.formattedDistance} da te'),
                        trailing: const Icon(Icons.star, color: Colors.amber),
                        onTap: () => Navigator.of(context).push(fadeSlideRoute(NearbyUserProfileScreen(user: user))),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
