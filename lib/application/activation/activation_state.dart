part of 'activation_cubit.dart';

sealed class ActivationState extends Equatable {
  const ActivationState();

  @override
  List<Object> get props => [];
}

final class ActivationValid extends ActivationState {
  final String id;
  final DateTime until;
  final bool disable;
  const ActivationValid(
      {required this.id, required this.until, required this.disable});

  @override
  List<Object> get props => [id, until, disable];
}

final class ActivationInvalid extends ActivationState {}
