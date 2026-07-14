import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock_auth_repository.dart';
import '../domain/auth_state.dart';

final authRepositoryProvider = Provider((ref) => MockAuthRepository());

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(ref.watch(authRepositoryProvider))..restoreSession();
});

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._repository) : super(const AuthInitial());

  final MockAuthRepository _repository;

  Future<void> restoreSession() async {
    final user = await _repository.restoreSession();
    state = user != null ? Authenticated(user) : const Unauthenticated();
  }

  Future<void> login({required String email, required String password}) async {
    state = const AuthLoading();
    try {
      final user = await _repository.login(email: email, password: password);
      state = Authenticated(user);
    } catch (_) {
      state = const Unauthenticated(errorMessage: 'Accesso non riuscito. Riprova.');
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    state = const AuthLoading();
    try {
      final user = await _repository.register(name: name, email: email, password: password);
      state = Authenticated(user);
    } catch (_) {
      state = const Unauthenticated(errorMessage: 'Registrazione non riuscita. Riprova.');
    }
  }

  Future<void> updateBio(String bio) async {
    final current = state;
    if (current is! Authenticated) return;
    await _repository.updateBio(current.user, bio);
    state = Authenticated(current.user.copyWith(bio: bio));
  }

  Future<void> updateAvatar(String avatarPath) async {
    final current = state;
    if (current is! Authenticated) return;
    await _repository.updateAvatar(current.user, avatarPath);
    state = Authenticated(current.user.copyWith(avatarPath: avatarPath));
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const Unauthenticated();
  }
}
