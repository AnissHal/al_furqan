import 'dart:async';

import 'package:al_furqan/application/services/asset_service.dart';
import 'package:al_furqan/models/users.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../models/student.dart';
import '../../services/student_service.dart';

part 'student_state.dart';

class StudentCubit extends Cubit<StudentState> {
  StudentCubit() : super(StudentInitial());

  StreamSubscription? _stream;

  void watchStudentsByTeacher(String id) {
    if (_stream != null) _stream!.cancel();

    StudentService.watchStudentsByTeacher(id).listen((e) {
      try {
        if (e.isEmpty) {
          emit(StudentEmpty());
          return;
        }

        e.removeWhere((e) => e.teacherId != id);
        emit(StudentLoaded(students: e));
      } catch (e) {
        emit(StudentError(message: e.toString()));
      }
    });
  }

  void getStudentsByTeacher(String id) {
    StudentService.getStudentsByTeacher(id)
        .then((value) => emit(StudentLoaded(students: value)))
        .catchError((e) => emit(StudentError(message: e.toString())));
  }

  void getStudentsByAdmin(String id) {
    StudentService.getStudents()
        .then((value) => emit(StudentLoaded(students: value)))
        .catchError((e) => emit(StudentError(message: e.toString())));
  }

  void watchStudentsByAdmin(String id) {
    if (_stream != null) _stream!.cancel();
    StudentService.watchStudentsByAdmin(id).listen((e) {
      try {
        if (e.isEmpty) {
          emit(StudentEmpty());
          return;
        }
        emit(StudentLoaded(students: e));
      } catch (e) {
        emit(StudentError(message: e.toString()));
      }
    });
  }

  Future<void> addStudent(
      {required String name,
      required int age,
      required Users teacher,
      required Users parent,
      String phone = '',
      XFile? image}) async {
    try {
      final id = await StudentService.addStudent(
          fullName: name,
          age: age,
          teacher: teacher,
          parent: parent,
          phone: phone);
      if (image != null) {
        await AssetService.uploadStudentAvatar(image, id, teacher.schoolId);
      }
    } catch (e) {
      rethrow;
    }
  }

  void disposeStream() {
    _stream?.cancel();
  }

  Future<void> studentByParent(String parentId) async {
    try {
      final students = await StudentService.getStudentsByParent(parentId);
      if (students.isEmpty) {
        emit(StudentEmpty());
        return;
      }
      emit(StudentLoaded(students: students));
    } catch (e) {
      rethrow;
    }
  }

  void closeStream() {
    _stream?.cancel();
  }

  @override
  Future<void> close() async {
    _stream?.cancel();
    return super.close();
  }
}
