import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/router/page_transitions.dart';
import '../../../../core/widgets/intent_chip.dart';
import '../../../../core/widgets/staggered_fade_in.dart';
import '../../../chat/presentation/chat_controller.dart';
import '../../../chat/presentation/screens/chat_detail_screen.dart';
import '../../../proximity/data/mock_proximity_repository.dart';
import '../../../proximity/domain/nearby_user.dart';
import '../../../proximity/presentation/screens/nearby_user_profile_screen.dart';
import '../../../proximity/presentation/user_relations_controller.dart';

/// Map view of nearby users (secondary to the default list view). No own
/// Scaffold/AppBar — meant to be embedded as a body by [NearbyScreen].
class NearbyMapView extends StatelessWidget {
  const NearbyMapView({super.key, required this.users});

  final List<NearbyUser> users;

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: const MapOptions(
        initialCenter: MockProximityRepository.myLocation,
        initialZoom: 15,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'app.proxi',
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: MockProximityRepository.myLocation,
              width: 24,
              height: 24,
              child: const _MeMarker(),
            ),
            for (final (index, user) in users.indexed)
              Marker(
                point: user.position,
                width: 44,
                height: 44,
                child: StaggeredFadeIn(
                  delay: Duration(milliseconds: index * 60),
                  child: _NearbyUserMarker(user: user),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _MeMarker extends StatelessWidget {
  const _MeMarker();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).colorScheme.primary,
        border: Border.all(color: Colors.white, width: 3),
      ),
    );
  }
}

class _NearbyUserMarker extends StatelessWidget {
  const _NearbyUserMarker({required this.user});

  final NearbyUser user;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showNearbyUserSheet(context, user),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: user.isOnline
                ? Theme.of(context).colorScheme.secondary
                : Colors.grey,
            child: Text(
              user.profile.initials,
              style: const TextStyle(fontSize: 12, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

/// Quick-actions sheet shown when tapping a nearby user, from either the
/// map or the list view.
void showNearbyUserSheet(BuildContext context, NearbyUser user) {
  showModalBottomSheet(
    context: context,
    builder: (context) => _NearbyUserSheet(user: user),
  );
}

class _NearbyUserSheet extends ConsumerWidget {
  const _NearbyUserSheet({required this.user});

  final NearbyUser user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorite = ref.watch(userRelationsControllerProvider).favoriteIds.contains(user.profile.id);
    final intent = user.profile.intent;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(fadeSlideRoute(NearbyUserProfileScreen(user: user)));
              },
              child: Row(
                children: [
                  CircleAvatar(radius: 24, child: Text(user.profile.initials)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.profile.name, style: Theme.of(context).textTheme.titleMedium),
                        Text('A ${user.formattedDistance} da te'),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ),
            if (intent != null) ...[
              const SizedBox(height: 12),
              IntentChip(intent: intent),
            ],
            if (user.profile.bio.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(user.profile.bio),
            ],
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(fadeSlideRoute(ChatDetailScreen(peer: user.profile)));
                    },
                    icon: const Icon(Icons.chat_bubble_outline),
                    label: const Text('Messaggio'),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () {
                    ref.read(chatControllerProvider.notifier).sendMessage(user.profile, '👋');
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Hai salutato ${user.profile.name}!')),
                    );
                  },
                  child: const Text('👋'),
                ),
                const SizedBox(width: 8),
                IconButton.outlined(
                  onPressed: () =>
                      ref.read(userRelationsControllerProvider.notifier).toggleFavorite(user.profile.id),
                  icon: Icon(isFavorite ? Icons.star : Icons.star_border,
                      color: isFavorite ? Colors.amber : null),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
