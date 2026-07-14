import 'package:go_router/go_router.dart';

import '../widgets/auth_gate.dart';

/// Central navigation graph for Proxi. Screens below the auth gate manage
/// their own internal navigation (bottom nav + pushed routes).
final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const AuthGate()),
  ],
);
