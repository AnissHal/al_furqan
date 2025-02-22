part of 'student_cubit.dart';

sealed class StudentState extends Equatable {
  const StudentState();

  @override
  List<Object> get props => [];
}

final class StudentInitial extends StudentState {}

final class StudentEmpty extends StudentState {}

final class StudentError extends StudentState {
  final String message;
  const StudentError({required this.message});
}

final class StudentLoaded extends StudentState {
  final List<Student> students;
  const StudentLoaded({required this.students});

  @override
  List<Object> get props => [students];
}
