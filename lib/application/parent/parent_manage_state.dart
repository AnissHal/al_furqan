part of 'parent_manage_cubit.dart';

sealed class ParentManageState extends Equatable {
  const ParentManageState();

  @override
  List<Object> get props => [];
}

final class ParentManageInitial extends ParentManageState {}

final class ParentManageLoaded extends ParentManageState {
  final Users parent;

  const ParentManageLoaded({required this.parent});
  @override
  List<Object> get props => [parent];
}
