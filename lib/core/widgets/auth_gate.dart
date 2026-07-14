import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/domain/auth_state.dart';
import '../../features/auth/presentation/auth_controller.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/home/presentation/screens/home_shell.dart';

/// Shows the login flow or the authenticated app shell depending on the
/// current session state.
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    return switch (authState) {
      AuthInitial() => const Scaffold(body: Center(child: CircularProgressIndicator())),
      AuthLoading() || Unauthenticated() => const LoginScreen(),
      Authenticated() => const HomeShell(),
    };
  }
}
