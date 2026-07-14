import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../chat/presentation/screens/chat_detail_screen.dart';
import '../../../proximity/data/mock_proximity_repository.dart';
import '../../../proximity/domain/nearby_user.dart';
import '../../../proximity/presentation/proximity_providers.dart';

class ProximityMapScreen extends ConsumerWidget {
  const ProximityMapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nearbyUsersAsync = ref.watch(nearbyUsersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Nelle vicinanze')),
      body: nearbyUsersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Errore: $error')),
        data: (users) => _MapView(users: users),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => ref.invalidate(nearbyUsersProvider),
        tooltip: 'Aggiorna',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}

class _MapView extends StatelessWidget {
  const _MapView({required this.users});

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
            for (final user in users)
              Marker(
                point: user.position,
                width: 44,
                height: 44,
                child: _NearbyUserMarker(user: user),
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
      onTap: () => _showUserSheet(context, user),
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

void _showUserSheet(BuildContext context, NearbyUser user) {
  showModalBottomSheet(
    context: context,
    builder: (context) => _NearbyUserSheet(user: user),
  );
}

class _NearbyUserSheet extends StatelessWidget {
  const _NearbyUserSheet({required this.user});

  final NearbyUser user;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
              ],
            ),
            if (user.profile.bio.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(user.profile.bio),
            ],
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => ChatDetailScreen(peer: user.profile),
                  ),
                );
              },
              icon: const Icon(Icons.chat_bubble_outline),
              label: const Text('Invia messaggio'),
            ),
          ],
        ),
      ),
    );
  }
}
