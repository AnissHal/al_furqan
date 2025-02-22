import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'activation_state.dart';

class ActivationCubit extends Cubit<ActivationState> {
  ActivationCubit() : super(ActivationInvalid());

  void listen() async {}
}
