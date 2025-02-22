part of 'parent_cubit.dart';

sealed class ParentsState extends Equatable {
  const ParentsState();

  @override
  List<Object> get props => [];
}

final class ParentsInitial extends ParentsState {}

final class ParentsError extends ParentsState {
  final String message;
  const ParentsError({required this.message});
}

final class ParentsLoaded extends ParentsState {
  final List<Users> parents;
  const ParentsLoaded({required this.parents});

  @override
  List<Object> get props => [parents];
}

final class ParentsEmpty extends ParentsState {}
