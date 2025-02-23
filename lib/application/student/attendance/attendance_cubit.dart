import 'dart:async';

import 'package:al_furqan/application/services/attendance_service.dart';
import 'package:al_furqan/models/attendance.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

part 'attendance_state.dart';

class AttendanceCubit extends Cubit<AttendanceState> {
  AttendanceCubit() : super(AttendanceInitial());

  StreamSubscription? _stream;

  void watchAttendance(String studentId) {
    _stream?.cancel();
    _stream =
        AttendanceService.streamAttendance(studentId).listen((attendances) {
      try {
        if (attendances.isEmpty) {
          emit(AttendanceLoaded(
              attendances: const [], DateTime.now().toIso8601String()));
          return;
        }
        emit(AttendanceLoaded(
            attendances: attendances, DateTime.now().toIso8601String()));
      } catch (e) {
        emit(AttendanceError(message: e.toString()));
      }
    });
  }

  void getttendance(String studentId) {
    AttendanceService.getAttendance(studentId).then((attendances) {
      try {
        if (attendances.isEmpty) {
          emit(AttendanceLoaded(
              attendances: const [], DateTime.now().toIso8601String()));
          return;
        }
        emit(AttendanceLoaded(
            attendances: attendances, DateTime.now().toIso8601String()));
      } catch (e) {
        emit(AttendanceError(message: e.toString()));
      }
    });
  }

  Future<void> fetchAttendanceByDate(DateTime d) async {
    try {
      AttendanceService.fetchAttendanceByDate(d).then((v) {
        emit(AttendanceLoaded(attendances: v, d.toIso8601String()));
      });
    } catch (e) {
      rethrow;
    }
  }

  getCalendarDataSource(List<Attendance> attendances) =>
      AttendanceDataSource(attendances);

  Future<void> addAttendance(String studentId, String teacherId, DateTime date,
      AttendanceStatus status) async {
    try {
      await AttendanceService.addAttendance(studentId, teacherId, date, status);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> removeAttendance(String id) async {
    try {
      return await AttendanceService.removeAttendance(id);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> markAbsent(
          String studentId, String teacherId, DateTime date) async =>
      await addAttendance(studentId, teacherId, date, AttendanceStatus.absent);

  Future<void> markPresent(
          String studentId, String teacherId, DateTime date) async =>
      await addAttendance(studentId, teacherId, date, AttendanceStatus.present);

  Future<void> markLate(
          String studentId, String teacherId, DateTime date) async =>
      await addAttendance(studentId, teacherId, date, AttendanceStatus.late);

  @override
  Future<void> close() {
    _stream?.cancel();
    return super.close();
  }
}

class AttendanceDataSource extends CalendarDataSource {
  AttendanceDataSource(List<Attendance> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) => appointments![index].date;

  @override
  DateTime getEndTime(int index) => appointments![index].date;

  @override
  String getSubject(int index) => appointments![index].status.toString();

  @override
  bool isAllDay(int index) => true;

  @override
  Color getColor(int index) => switch (appointments![index].status) {
        AttendanceStatus.absent => Colors.red,
        AttendanceStatus.late => Colors.yellow,
        _ => Colors.green
      };
}
