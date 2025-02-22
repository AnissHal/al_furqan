part of 'school_cubit.dart';

sealed class SchoolState extends Equatable {
  const SchoolState();

  @override
  List<Object> get props => [];
}

final class SchoolInitial extends SchoolState {}

final class SchoolLoaded extends SchoolState {
  final Schools school;

  const SchoolLoaded({required this.school});
  @override
  List<Object> get props => [school];
}
