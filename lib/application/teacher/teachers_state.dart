part of 'teachers_cubit.dart';

sealed class TeachersState extends Equatable {
  const TeachersState();

  @override
  List<Object> get props => [];
}

final class TeachersInitial extends TeachersState {}

final class TeachersLoaded extends TeachersState {
  final List<Users> teachers;

  const TeachersLoaded({required this.teachers});

  @override
  List<Object> get props => [teachers];
}

final class TeachersError extends TeachersState {
  final String message;

  const TeachersError({required this.message});
  @override
  List<Object> get props => [message];
}
