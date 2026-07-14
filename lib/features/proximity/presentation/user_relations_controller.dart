import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tracks which nearby users the current user has favorited or blocked.
/// Persisted locally so the choices survive app restarts.
class UserRelationsState {
  const UserRelationsState({this.favoriteIds = const {}, this.blockedIds = const {}});

  final Set<String> favoriteIds;
  final Set<String> blockedIds;

  UserRelationsState copyWith({Set<String>? favoriteIds, Set<String>? blockedIds}) {
    return UserRelationsState(
      favoriteIds: favoriteIds ?? this.favoriteIds,
      blockedIds: blockedIds ?? this.blockedIds,
    );
  }
}

final userRelationsControllerProvider =
    StateNotifierProvider<UserRelationsController, UserRelationsState>((ref) {
  return UserRelationsController()..load();
});

class UserRelationsController extends StateNotifier<UserRelationsState> {
  UserRelationsController() : super(const UserRelationsState());

  static const _keyFavorites = 'relations.favoriteIds';
  static const _keyBlocked = 'relations.blockedIds';

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    state = UserRelationsState(
      favoriteIds: (prefs.getStringList(_keyFavorites) ?? []).toSet(),
      blockedIds: (prefs.getStringList(_keyBlocked) ?? []).toSet(),
    );
  }

  Future<void> toggleFavorite(String userId) async {
    final favorites = {...state.favoriteIds};
    if (!favorites.remove(userId)) favorites.add(userId);
    state = state.copyWith(favoriteIds: favorites);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyFavorites, favorites.toList());
  }

  Future<void> block(String userId) async {
    final blocked = {...state.blockedIds, userId};
    final favorites = {...state.favoriteIds}..remove(userId);
    state = state.copyWith(blockedIds: blocked, favoriteIds: favorites);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyBlocked, blocked.toList());
    await prefs.setStringList(_keyFavorites, favorites.toList());
  }

  bool isFavorite(String userId) => state.favoriteIds.contains(userId);

  bool isBlocked(String userId) => state.blockedIds.contains(userId);
}
