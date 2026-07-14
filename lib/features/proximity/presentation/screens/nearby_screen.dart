import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../map/presentation/screens/proximity_map_screen.dart';
import '../proximity_providers.dart';
import 'nearby_list_view.dart';

/// Root "Vicinanze" tab: a scrollable list of nearby users by default, with
/// a toggle to switch to the map view when spatial context is useful.
class NearbyScreen extends ConsumerStatefulWidget {
  const NearbyScreen({super.key});

  @override
  ConsumerState<NearbyScreen> createState() => _NearbyScreenState();
}

class _NearbyScreenState extends ConsumerState<NearbyScreen> {
  bool _showMap = false;

  @override
  Widget build(BuildContext context) {
    final nearbyUsersAsync = ref.watch(nearbyUsersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nelle vicinanze'),
        actions: [
          IconButton(
            tooltip: _showMap ? 'Vedi come lista' : 'Vedi sulla mappa',
            onPressed: () => setState(() => _showMap = !_showMap),
            icon: Icon(_showMap ? Icons.view_list_rounded : Icons.map_outlined),
          ),
        ],
      ),
      body: nearbyUsersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Errore: $error')),
        data: (users) => PageTransitionSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, primaryAnimation, secondaryAnimation) => FadeThroughTransition(
            animation: primaryAnimation,
            secondaryAnimation: secondaryAnimation,
            child: child,
          ),
          child: _showMap
              ? NearbyMapView(key: const ValueKey('map'), users: users)
              : NearbyListView(key: const ValueKey('list'), users: users),
        ),
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
