import 'user_intent.dart';

/// A Proxi user profile.
class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    this.bio = '',
    this.avatarPath,
    this.intent,
  });

  final String id;
  final String name;
  final String email;
  final String bio;

  /// Local file path of a custom profile photo, if the user set one.
  final String? avatarPath;

  /// What this user is currently open to (shown as a badge), if set.
  final UserIntent? intent;

  /// Deterministic initials used for the placeholder avatar.
  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    final first = parts.first[0];
    final last = parts.length > 1 ? parts.last[0] : '';
    return (first + last).toUpperCase();
  }

  AppUser copyWith({
    String? name,
    String? bio,
    String? avatarPath,
    UserIntent? intent,
    bool clearIntent = false,
  }) =>
      AppUser(
        id: id,
        name: name ?? this.name,
        email: email,
        bio: bio ?? this.bio,
        avatarPath: avatarPath ?? this.avatarPath,
        intent: clearIntent ? null : (intent ?? this.intent),
      );
}
