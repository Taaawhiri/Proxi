/// Application-wide constants for Proxi.
class AppConstants {
  AppConstants._();

  static const String appName = 'Proxi';

  /// Default radius (in meters) used to discover nearby users.
  static const double defaultProximityRadiusMeters = 500;

  /// Maximum radius (in meters) selectable by the user.
  static const double maxProximityRadiusMeters = 5000;

  /// Base URL for the backend REST API. Override via --dart-define in CI.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.proxi.app',
  );

  /// Base URL for the realtime chat WebSocket gateway.
  static const String wsBaseUrl = String.fromEnvironment(
    'WS_BASE_URL',
    defaultValue: 'wss://ws.proxi.app',
  );
}
