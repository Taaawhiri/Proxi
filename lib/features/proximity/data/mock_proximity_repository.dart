import 'dart:math';

import 'package:latlong2/latlong.dart';

import '../../auth/domain/app_user.dart';
import '../domain/nearby_user.dart';

/// Fake nearby-users feed, centered on a fixed demo location. Replace with a
/// real geolocation + backend query once available.
class MockProximityRepository {
  /// Piazza del Duomo, Milano — used as the demo "you are here" point.
  static const myLocation = LatLng(45.4642, 9.1900);

  static final _distanceCalculator = Distance();

  static final _seedNames = [
    'Giulia',
    'Marco',
    'Sara',
    'Luca',
    'Chiara',
    'Davide',
    'Elena',
    'Francesco',
    'Alice',
    'Matteo',
  ];

  Future<List<NearbyUser>> fetchNearbyUsers() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final random = Random(42);

    final users = List.generate(_seedNames.length, (index) {
      final name = _seedNames[index];
      final angle = random.nextDouble() * 2 * pi;
      final distanceMeters = 30.0 + random.nextDouble() * 850;
      final position = _distanceCalculator.offset(myLocation, distanceMeters, angle * 180 / pi);

      return NearbyUser(
        profile: AppUser(
          id: 'demo-$index',
          name: name,
          email: '${name.toLowerCase()}@example.com',
          bio: 'Amante della città e delle nuove connessioni.',
        ),
        position: position,
        distanceMeters: distanceMeters,
        isOnline: random.nextBool() || index.isEven,
      );
    });

    users.sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));
    return users;
  }
}
