part of 'student_manage_cubit.dart';

sealed class StudentManageState extends Equatable {
  const StudentManageState();

  @override
  List<Object> get props => [];
}

final class StudentManageInitial extends StudentManageState {}

final class StudentManageLoaded extends StudentManageState {
  final Student student;
  final List<Progress> progress;

  const StudentManageLoaded({
    required this.student,
    required this.progress,
  });

  @override
  List<Object> get props => [student, progress];

  StudentManageLoaded copyWith({
    Student? student,
    List<Progress>? progress,
  }) {
    return StudentManageLoaded(
      student: student ?? this.student,
      progress: progress ?? this.progress,
    );
  }
}

final class StudentManageError extends StudentManageState {
  final String message;

  const StudentManageError({required this.message});

  @override
  List<Object> get props => [message];
}
