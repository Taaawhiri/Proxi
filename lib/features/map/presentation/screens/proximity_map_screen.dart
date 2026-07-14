import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/router/page_transitions.dart';
import '../../../chat/presentation/chat_controller.dart';
import '../../../chat/presentation/screens/chat_detail_screen.dart';
import '../../../proximity/data/mock_proximity_repository.dart';
import '../../../proximity/domain/nearby_user.dart';
import '../../../proximity/presentation/proximity_providers.dart';
import '../../../proximity/presentation/screens/nearby_user_profile_screen.dart';
import '../../../proximity/presentation/user_relations_controller.dart';

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
      floatingActionButton: _RefreshFab(
        isLoading: nearbyUsersAsync.isLoading,
        onPressed: () => ref.invalidate(rawNearbyUsersProvider),
      ),
    );
  }
}

class _RefreshFab extends StatefulWidget {
  const _RefreshFab({required this.isLoading, required this.onPressed});

  final bool isLoading;
  final VoidCallback onPressed;

  @override
  State<_RefreshFab> createState() => _RefreshFabState();
}

class _RefreshFabState extends State<_RefreshFab> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  );

  @override
  void didUpdateWidget(covariant _RefreshFab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading) {
      _controller.repeat();
    } else {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: widget.isLoading ? null : widget.onPressed,
      tooltip: 'Aggiorna',
      child: RotationTransition(turns: _controller, child: const Icon(Icons.refresh)),
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
            for (final (index, user) in users.indexed)
              Marker(
                point: user.position,
                width: 44,
                height: 44,
                child: _PopIn(delay: Duration(milliseconds: index * 60), child: _NearbyUserMarker(user: user)),
              ),
          ],
        ),
      ],
    );
  }
}

/// Staggered scale + fade entrance used for map markers, evoking a radar
/// "ping" reveal as nearby users are discovered.
class _PopIn extends StatefulWidget {
  const _PopIn({required this.child, this.delay = Duration.zero});

  final Widget child;
  final Duration delay;

  @override
  State<_PopIn> createState() => _PopInState();
}

class _PopInState extends State<_PopIn> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 350),
  );
  Timer? _delayTimer;

  @override
  void initState() {
    super.initState();
    _delayTimer = Timer(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _delayTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    return ScaleTransition(
      scale: curved,
      child: FadeTransition(opacity: _controller, child: widget.child),
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

class _NearbyUserSheet extends ConsumerWidget {
  const _NearbyUserSheet({required this.user});

  final NearbyUser user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorite = ref.watch(userRelationsControllerProvider).favoriteIds.contains(user.profile.id);

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
