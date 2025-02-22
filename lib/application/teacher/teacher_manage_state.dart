part of 'teacher_manage_cubit.dart';

sealed class TeacherManageState extends Equatable {
  const TeacherManageState();

  @override
  List<Object> get props => [];
}

final class TeacherManageInitial extends TeacherManageState {}

final class TeacherManageLoaded extends TeacherManageState {
  final Users teacher;

  const TeacherManageLoaded({required this.teacher});

  @override
  List<Object> get props => [teacher];
}
