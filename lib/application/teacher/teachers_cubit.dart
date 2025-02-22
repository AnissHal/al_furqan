import 'dart:async';

import 'package:al_furqan/application/services/teacher_service.dart';
import 'package:al_furqan/application/services/users_service.dart';
import 'package:al_furqan/models/users.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'teachers_state.dart';

class TeachersCubit extends Cubit<TeachersState> {
  TeachersCubit() : super(TeachersInitial());

  StreamSubscription<List<Users>>? _stream;

  void watchTeachers(String schoolId) {
    _stream?.cancel();
    _stream = TeacherService.getTeachers(schoolId).listen((e) {
      e.removeWhere((e) => e.role == UserRole.parent);
      emit(TeachersLoaded(teachers: e));
    });

    _stream!.onError((error) {
      if (error is RealtimeSubscribeException) {
        // emit(TeachersError(message: error.status.name));
        return;
      }
      // emit(TeachersError(message: error.toString()));
    });
  }

  void deleteTeacher(
    Users teacher,
  ) {
    if (teacher.role != UserRole.teacher) return;
    UsersService.deleteTeacher(teacher);
  }

  @override
  Future<void> close() {
    _stream?.cancel();
    return super.close();
  }
}
