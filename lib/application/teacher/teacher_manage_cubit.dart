import 'dart:async';

import 'package:al_furqan/application/services/asset_service.dart';
import 'package:al_furqan/application/services/users_service.dart';
import 'package:al_furqan/models/users.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

part 'teacher_manage_state.dart';

class TeacherManageCubit extends Cubit<TeacherManageState> {
  TeacherManageCubit() : super(TeacherManageInitial());

  StreamSubscription? teacherStream;
  void loadTeacher(Users teacher) {
    teacherStream = UsersService.watchUser(teacher.id).listen((e) {
      if (e == null) return;
      emit(TeacherManageLoaded(teacher: e));
    });
  }

  Future<void> removeTeacherImage() async {
    if (state is! TeacherManageLoaded) return;
    final s = state as TeacherManageLoaded;
    await AssetService.removeAvatar(
        s.teacher.id, s.teacher.image!, s.teacher.schoolId);
  }

  Future<String?> updateTeacherImage(XFile avatar) async {
    if (state is! TeacherManageLoaded) return null;
    final s = state as TeacherManageLoaded;
    return await AssetService.updateAvatar(
        avatar, s.teacher.image, s.teacher.id, s.teacher.schoolId, false);
  }

  @override
  Future<void> close() {
    teacherStream?.cancel();
    return super.close();
  }
}
