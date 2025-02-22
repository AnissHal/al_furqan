part of 'auth_cubit.dart';

final class AuthNotAuthenticated extends AuthState {
  final AuthError? message;
  final String id;

  const AuthNotAuthenticated(this.id, {this.message});

  @override
  List<Object> get props => [message ?? '', id];
}

final class AuthParentAuthenticated extends AuthState {
  final Parent parent;
  const AuthParentAuthenticated({required this.parent});

  @override
  List<Object> get props => [parent];
}

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

final class AuthUserCreating extends AuthState {}

final class AuthUserLogin extends AuthState {}

final class UserAuthenticated extends AuthState {
  final User supabaseUser;
  final Users? userData;
  const UserAuthenticated({required this.supabaseUser, this.userData});

  @override
  List<Object> get props => [supabaseUser, userData ?? Users.empty()];
}
