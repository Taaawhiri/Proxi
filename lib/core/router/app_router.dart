import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/map/presentation/screens/proximity_map_screen.dart';

/// Central navigation graph for Proxi.
final GoRouter appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/map',
      builder: (context, state) => const ProximityMapScreen(),
    ),
  ],
);
