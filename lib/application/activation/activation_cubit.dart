import 'package:al_furqan/application/services/school_service.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'activation_state.dart';

class ActivationCubit extends Cubit<ActivationState> {
  ActivationCubit()
      : super(ActivationValid(
            id: '',
            until: DateTime.now().add(const Duration(days: 365)),
            disable: false));

  void getActivation(String schoolId) async {
    final active = await SchoolService.getActivation(schoolId);
    active
        ? emit(ActivationValid(
            id: schoolId,
            until: DateTime.now().add(const Duration(days: 365)),
            disable: false))
        : emit(ActivationInvalid());
  }
}
