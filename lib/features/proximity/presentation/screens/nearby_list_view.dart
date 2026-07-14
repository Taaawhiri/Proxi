import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/router/page_transitions.dart';
import '../../../../core/widgets/intent_chip.dart';
import '../../../../core/widgets/staggered_slide_fade_in.dart';
import '../../../chat/presentation/chat_controller.dart';
import '../../../chat/presentation/screens/chat_detail_screen.dart';
import '../../../map/presentation/screens/proximity_map_screen.dart' show showNearbyUserSheet;
import '../../domain/nearby_user.dart';
import 'nearby_user_profile_screen.dart';

/// Default, list-based view of nearby users: one row per person, ordered by
/// distance, with quick actions at a glance.
class NearbyListView extends StatelessWidget {
  const NearbyListView({super.key, required this.users});

  final List<NearbyUser> users;

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) {
      return const Center(child: Text('Nessuno nelle vicinanze al momento.'));
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: users.length,
      separatorBuilder: (context, index) => const Divider(height: 1, indent: 76),
      itemBuilder: (context, index) => StaggeredSlideFadeIn(
        delay: Duration(milliseconds: index * 50),
        child: _NearbyUserRow(user: users[index]),
      ),
    );
  }
}

class _NearbyUserRow extends ConsumerWidget {
  const _NearbyUserRow({required this.user});

  final NearbyUser user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final intent = user.profile.intent;

    return InkWell(
      onTap: () => showNearbyUserSheet(context, user),
      onLongPress: () => Navigator.of(context)
          .push(fadeSlideRoute(NearbyUserProfileScreen(user: user))),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor:
                      user.isOnline ? Theme.of(context).colorScheme.secondary : Colors.grey,
                  child: Text(user.profile.initials, style: const TextStyle(color: Colors.white)),
                ),
                if (user.isOnline)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          user.profile.name,
                          style: Theme.of(context).textTheme.titleMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        user.formattedDistance,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  if (intent != null) ...[
                    const SizedBox(height: 6),
                    IntentChip(intent: intent, dense: true),
                  ],
                  if (user.profile.bio.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      user.profile.bio,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
            Column(
              children: [
                IconButton(
                  tooltip: 'Messaggio',
                  onPressed: () => Navigator.of(context)
                      .push(fadeSlideRoute(ChatDetailScreen(peer: user.profile))),
                  icon: const Icon(Icons.chat_bubble_outline),
                ),
                IconButton(
                  tooltip: 'Saluta',
                  onPressed: () {
                    ref.read(chatControllerProvider.notifier).sendMessage(user.profile, '👋');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Hai salutato ${user.profile.name}!')),
                    );
                  },
                  icon: const Text('👋'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
