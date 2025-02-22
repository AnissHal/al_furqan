import 'dart:async';

import 'package:al_furqan/application/services/parent_service.dart';
import 'package:al_furqan/application/services/teacher_service.dart';
import 'package:al_furqan/models/users.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'parent_state.dart';

// custom exception class
class ParentException implements Exception {
  ParentException();
}

class ParentCubit extends Cubit<ParentsState> {
  ParentCubit() : super(ParentsInitial());

  StreamSubscription? _stream;

  Future<void> addParent(
      String name, String phone, String username, String password,
      {String address = ''}) async {
    try {
      if (await ParentService.doesParentExist(username) ||
          await TeacherService.find(username) != null) {
        throw ParentException();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> removeParent(String id) async {
    try {
      await ParentService.removeParent(id);
    } catch (e) {
      rethrow;
    }
  }

  void watchParents(Users teacher) {
    _stream?.cancel();
    _stream = ParentService.getParents(schoolId: teacher.schoolId).listen((e) {
      try {
        e.removeWhere((e) => e.role != UserRole.parent);
        // if (parents.isEmpty) {
        //   emit(ParentsEmpty());
        //   return;
        // }
        emit(ParentsLoaded(parents: e));
      } catch (e) {
        emit(ParentsError(message: e.toString()));
        rethrow;
      }
    });
  }

  @override
  Future<void> close() {
    _stream?.cancel();
    super.close();
    return Future.value();
  }
}
