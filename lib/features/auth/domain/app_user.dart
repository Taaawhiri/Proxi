/// A Proxi user profile.
class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    this.bio = '',
  });

  final String id;
  final String name;
  final String email;
  final String bio;

  /// Deterministic initials used for the placeholder avatar.
  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    final first = parts.first[0];
    final last = parts.length > 1 ? parts.last[0] : '';
    return (first + last).toUpperCase();
  }

  AppUser copyWith({String? name, String? bio}) => AppUser(
        id: id,
        name: name ?? this.name,
        email: email,
        bio: bio ?? this.bio,
      );
}
