part of 'profile_cubit.dart';

sealed class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object> get props => [];
}

final class ProfileInitial extends ProfileState {}

final class ProfileLoaded extends ProfileState {
  final Users user;

  const ProfileLoaded({required this.user});
  @override
  List<Object> get props => [user];
}
