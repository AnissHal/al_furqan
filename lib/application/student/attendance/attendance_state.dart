part of 'attendance_cubit.dart';

sealed class AttendanceState extends Equatable {
  const AttendanceState();

  @override
  List<Object> get props => [];
}

final class AttendanceInitial extends AttendanceState {}

final class AttendanceLoaded extends AttendanceState {
  final List<Attendance> attendances;
  const AttendanceLoaded({required this.attendances});

  @override
  List<Object> get props => [attendances];
}

final class AttendanceError extends AttendanceState {
  final String message;
  const AttendanceError({required this.message});
}
