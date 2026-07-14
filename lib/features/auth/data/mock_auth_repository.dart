import 'package:shared_preferences/shared_preferences.dart';

import '../domain/app_user.dart';

/// Fake authentication backend: accepts any well-formed credentials and
/// persists the session locally. Replace with a real API client once the
/// backend is available.
class MockAuthRepository {
  static const _keyUserId = 'auth.userId';
  static const _keyUserName = 'auth.userName';
  static const _keyUserEmail = 'auth.userEmail';
  static const _keyUserBio = 'auth.userBio';
  static const _keyUserAvatarPath = 'auth.userAvatarPath';

  Future<AppUser?> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(_keyUserId);
    final name = prefs.getString(_keyUserName);
    final email = prefs.getString(_keyUserEmail);
    if (id == null || name == null || email == null) return null;
    return AppUser(
      id: id,
      name: name,
      email: email,
      bio: prefs.getString(_keyUserBio) ?? '',
      avatarPath: prefs.getString(_keyUserAvatarPath),
    );
  }

  Future<AppUser> login({required String email, required String password}) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    final name = email.split('@').first;
    final user = AppUser(
      id: email.toLowerCase(),
      name: name.isEmpty ? 'Utente Proxi' : _capitalize(name),
      email: email,
    );
    await _persist(user);
    return user;
  }

  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    final user = AppUser(id: email.toLowerCase(), name: name, email: email);
    await _persist(user);
    return user;
  }

  Future<void> updateBio(AppUser user, String bio) async {
    final updated = user.copyWith(bio: bio);
    await _persist(updated);
  }

  Future<void> updateAvatar(AppUser user, String avatarPath) async {
    final updated = user.copyWith(avatarPath: avatarPath);
    await _persist(updated);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUserName);
    await prefs.remove(_keyUserEmail);
    await prefs.remove(_keyUserBio);
    await prefs.remove(_keyUserAvatarPath);
  }

  Future<void> _persist(AppUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserId, user.id);
    await prefs.setString(_keyUserName, user.name);
    await prefs.setString(_keyUserEmail, user.email);
    await prefs.setString(_keyUserBio, user.bio);
    final avatarPath = user.avatarPath;
    if (avatarPath != null) {
      await prefs.setString(_keyUserAvatarPath, avatarPath);
    }
  }

  String _capitalize(String value) =>
      value.isEmpty ? value : value[0].toUpperCase() + value.substring(1);
}
