import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock_proximity_repository.dart';
import '../domain/nearby_user.dart';
import 'user_relations_controller.dart';

final proximityRepositoryProvider = Provider((ref) => MockProximityRepository());

/// Raw nearby-users fetch (simulates a network call). Only re-runs when
/// explicitly invalidated (e.g. pull-to-refresh), independent of favorites
/// or blocks so those don't trigger a refetch.
final rawNearbyUsersProvider = FutureProvider<List<NearbyUser>>((ref) {
  return ref.watch(proximityRepositoryProvider).fetchNearbyUsers();
});

/// Nearby users with blocked profiles filtered out.
final nearbyUsersProvider = Provider<AsyncValue<List<NearbyUser>>>((ref) {
  final blockedIds = ref.watch(userRelationsControllerProvider).blockedIds;
  return ref.watch(rawNearbyUsersProvider).whenData(
        (users) => users.where((user) => !blockedIds.contains(user.profile.id)).toList(),
      );
});
