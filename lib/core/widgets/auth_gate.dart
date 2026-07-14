import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/domain/auth_state.dart';
import '../../features/auth/presentation/auth_controller.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/home/presentation/screens/home_shell.dart';

/// Shows the login flow or the authenticated app shell depending on the
/// current session state, cross-fading between them.
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    final (key, child) = switch (authState) {
      AuthInitial() => (
          'splash',
          const Scaffold(body: Center(child: CircularProgressIndicator())),
        ),
      AuthLoading() || Unauthenticated() => ('login', const LoginScreen()),
      Authenticated() => ('home', const HomeShell()),
    };

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween(begin: 0.98, end: 1.0).animate(animation),
          child: child,
        ),
      ),
      child: KeyedSubtree(key: ValueKey(key), child: child),
    );
  }
}
