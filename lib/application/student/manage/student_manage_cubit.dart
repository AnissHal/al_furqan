import 'dart:async';

import 'package:al_furqan/application/enums/encouragement.dart';
import 'package:al_furqan/application/services/asset_service.dart';
import 'package:al_furqan/application/services/progress_service.dart';
import 'package:al_furqan/application/services/student_service.dart';
import 'package:al_furqan/models/mutn.dart';
import 'package:al_furqan/models/progress.dart';
import 'package:al_furqan/models/quran_status.dart';
import 'package:al_furqan/models/student.dart';
import 'package:al_furqan/models/users.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

part 'student_manage_state.dart';

class StudentManageCubit extends Cubit<StudentManageState> {
  StudentManageCubit() : super(StudentManageInitial());

  StreamSubscription? _stream;

  void watchStudent(String id) {
    _stream?.cancel();
    _stream = StudentService.watchStudent(id).listen((e) async {
      try {
        if (e == null) {
          emit(const StudentManageError(message: "null"));
        } else {
          final progress = await ProgressService.getProgress(e.id);
          emit(StudentManageLoaded(student: e, progress: progress));
        }
      } catch (e) {
        emit(StudentManageError(message: e.toString()));
        rethrow;
      }
    });
  }

  List<QuranItem>? getQuranList() {
    if (state is! StudentManageLoaded) return null;
    final s = (state as StudentManageLoaded);
    try {
      if (s.progress.isEmpty) return null;

      return s.progress
          .where((e) => e.course == CourseType.quran)
          .map((e) => QuranItem(
              fromQuranStatus: QuranStatus(
                  count: e.count, titleAr: e.title, index: e.index.toString()),
              note: e.mark,
              fromAyah: e.from,
              toAyah: e.to,
              type: e.type))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  List<MutnItem>? getMutnList() {
    if (state is! StudentManageLoaded) return null;
    final s = (state as StudentManageLoaded);
    try {
      if (s.progress.isEmpty) return null;

      return s.progress
          .where((e) => e.course == CourseType.mutn)
          .map((e) => MutnItem(
              fromMutn: Mutn(count: e.count, titleAr: e.title, index: e.index),
              note: e.mark,
              from: e.from,
              to: e.to,
              type: e.type))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  void addQuran(QuranItem quran) async {
    if (state is! StudentManageLoaded) return;
    final id = (state as StudentManageLoaded).student.id;
    try {
      final progress = Progress(
          studentId: id,
          course: CourseType.quran,
          index: int.parse(quran.fromQuranStatus.index),
          count: quran.fromQuranStatus.count,
          title: quran.fromQuranStatus.titleAr,
          from: quran.fromAyah,
          to: quran.toAyah,
          type: quran.type,
          mark: quran.note);
      ProgressService.addProgress(progress);
    } catch (e) {
      rethrow;
    }
  }

  void refreshProgression() {
    if (state is! StudentManageLoaded) return;
    final s = (state as StudentManageLoaded);
    try {
      ProgressService.getProgress(s.student.id).then((progress) {
        emit(StudentManageLoaded(student: s.student, progress: progress));
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addMutn(MutnItem mutn) async {
    if (state is! StudentManageLoaded) return;
    final id = (state as StudentManageLoaded).student.id;

    try {
      final progress = Progress(
          studentId: id,
          course: CourseType.mutn,
          index: mutn.fromMutn.index,
          count: mutn.fromMutn.count,
          title: mutn.fromMutn.titleAr,
          from: mutn.from,
          to: mutn.to,
          type: mutn.type,
          mark: mutn.note);
      ProgressService.addProgress(progress);
    } catch (e) {
      rethrow;
    }
  }

  int getIdByQuranItem(QuranItem quranItem) {
    if (state is! StudentManageLoaded) return -1;
    final s = (state as StudentManageLoaded);
    final index = s.progress.indexWhere((e) => e.getQuranItem() == quranItem);
    return s.progress[index].id!;
  }

  int getIdByMutnItem(MutnItem mutnItem) {
    if (state is! StudentManageLoaded) return -1;
    final s = (state as StudentManageLoaded);
    final index = s.progress.indexWhere((e) => e.getMutnItem() == mutnItem);
    return s.progress[index].id!;
  }

  Future<void> updateQuranItem(QuranItem oldQuran, QuranItem newQuran) async {
    if (state is! StudentManageLoaded) return;
    final id = (state as StudentManageLoaded).student.id;

    try {
      final progressId = getIdByQuranItem(oldQuran);
      final progress = Progress(
          id: progressId,
          studentId: id,
          course: CourseType.quran,
          index: int.parse(newQuran.fromQuranStatus.index),
          count: newQuran.fromQuranStatus.count,
          title: newQuran.fromQuranStatus.titleAr,
          from: newQuran.fromAyah,
          to: newQuran.toAyah,
          type: newQuran.type,
          mark: newQuran.note);
      await ProgressService.updateProgress(progress);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateMutnItem(MutnItem oldMutn, MutnItem newMutn) async {
    if (state is! StudentManageLoaded) return;
    final id = (state as StudentManageLoaded).student.id;

    try {
      final progressId = getIdByMutnItem(oldMutn);
      final progress = Progress(
          id: progressId,
          studentId: id,
          course: CourseType.quran,
          index: newMutn.fromMutn.index,
          count: newMutn.fromMutn.count,
          title: newMutn.fromMutn.titleAr,
          from: newMutn.from,
          to: newMutn.to,
          type: newMutn.type,
          mark: newMutn.note);
      await ProgressService.updateProgress(progress);
    } catch (e) {
      rethrow;
    }
  }

  void removeQuranItem(QuranItem item) async {
    if (state is! StudentManageLoaded) return;

    try {
      final progressId = getIdByQuranItem(item);
      await ProgressService.deleteProgress(progressId);
    } catch (e) {
      rethrow;
    }
  }

  void removeMutnItem(MutnItem item) async {
    if (state is! StudentManageLoaded) return;

    try {
      final progressId = getIdByMutnItem(item);
      await ProgressService.deleteProgress(progressId);
    } catch (e) {
      rethrow;
    }
  }

  void toggleStudentRequest() async {
    if (state is! StudentManageLoaded) return;
    final id = (state as StudentManageLoaded).student.id;
    final s = state as StudentManageLoaded;
    try {
      await StudentService.toggleStudentRequest(id, s.student.requested);
      emit((state as StudentManageLoaded).copyWith(progress: s.progress));
    } catch (e) {
      rethrow;
    }
  }

  Future<String?> updateStudentImage(XFile file, Users teacher) async {
    if (state is! StudentManageLoaded) return null;
    final student = (state as StudentManageLoaded).student;
    try {
      if (student.image != null) {
        CachedNetworkImage.evictFromCache(
            AssetService.composeStudentImageURL(student));
        return await AssetService.updateAvatar(
            file, student.image!, student.id, student.schoolId, true);
      } else {
        return await AssetService.uploadStudentAvatar(
            file, student.id, student.schoolId);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> removeStudentImage() async {
    if (state is! StudentManageLoaded) return;
    final id = (state as StudentManageLoaded).student.id;
    final s = state as StudentManageLoaded;

    try {
      CachedNetworkImage.evictFromCache(
          AssetService.composeStudentImageURL(s.student));
      await AssetService.removeStudentAvatar(
          id, s.student.image!, s.student.schoolId);
    } catch (e) {
      rethrow;
    }
  }

  void updateMarkAndObservation(
      double? mark, Encouragement? encouragement, Behaviour? behaviour) async {
    if (state is! StudentManageLoaded) return;
    final id = (state as StudentManageLoaded).student.id;
    try {
      StudentService.updateStudentMarkandObservation(
          id: id,
          mark: mark,
          encouragement: encouragement,
          behaviour: behaviour);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future close() {
    _stream?.cancel();
    super.close();
    return Future.value();
  }
}
