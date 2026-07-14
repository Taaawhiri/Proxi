/// A Proxi user profile.
class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    this.bio = '',
    this.avatarPath,
  });

  final String id;
  final String name;
  final String email;
  final String bio;

  /// Local file path of a custom profile photo, if the user set one.
  final String? avatarPath;

  /// Deterministic initials used for the placeholder avatar.
  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    final first = parts.first[0];
    final last = parts.length > 1 ? parts.last[0] : '';
    return (first + last).toUpperCase();
  }

  AppUser copyWith({String? name, String? bio, String? avatarPath}) => AppUser(
        id: id,
        name: name ?? this.name,
        email: email,
        bio: bio ?? this.bio,
        avatarPath: avatarPath ?? this.avatarPath,
      );
}
