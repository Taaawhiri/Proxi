import 'app_user.dart';

/// Authentication status of the current session.
sealed class AuthState {
  const AuthState();
}

/// Session not yet restored from local storage.
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// A login/register/restore operation is in flight.
class AuthLoading extends AuthState {
  const AuthLoading();
}

class Unauthenticated extends AuthState {
  const Unauthenticated({this.errorMessage});

  final String? errorMessage;
}

class Authenticated extends AuthState {
  const Authenticated(this.user);

  final AppUser user;
}
