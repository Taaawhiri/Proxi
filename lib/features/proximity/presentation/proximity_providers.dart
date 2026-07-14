import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock_proximity_repository.dart';
import '../domain/nearby_user.dart';

final proximityRepositoryProvider = Provider((ref) => MockProximityRepository());

final nearbyUsersProvider = FutureProvider<List<NearbyUser>>((ref) {
  return ref.watch(proximityRepositoryProvider).fetchNearbyUsers();
});
