import 'package:latlong2/latlong.dart';

import '../../auth/domain/app_user.dart';

/// A user discovered nearby, with their approximate position and distance.
class NearbyUser {
  const NearbyUser({
    required this.profile,
    required this.position,
    required this.distanceMeters,
    this.isOnline = true,
  });

  final AppUser profile;
  final LatLng position;
  final double distanceMeters;
  final bool isOnline;

  String get formattedDistance => distanceMeters < 1000
      ? '${distanceMeters.round()} m'
      : '${(distanceMeters / 1000).toStringAsFixed(1)} km';
}
