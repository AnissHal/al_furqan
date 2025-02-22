import 'package:al_furqan/models/attendance.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/v7.dart';

class AttendanceService {
  static final db = Supabase.instance.client;

  static Stream<List<Attendance>> streamAttendance(String studentId) {
    try {
      return db
          .from('attendance')
          .stream(primaryKey: ['id'])
          .eq('student_id', studentId)
          .map((e) => e.map((e) => Attendance.fromFirestore(e)).toList());
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<Attendance>> getAttendance(String studentId) async {
    try {
      return (await db.from('attendance').select().eq('student_id', studentId))
          .map((e) => Attendance.fromFirestore(e))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<Attendance>> fetchAttendanceByDate(DateTime d) async {
    try {
      final today = DateTime(d.year, d.month, d.day).toIso8601String();
      return (await db.from('attendance').select().eq('date', today))
          .map((e) => Attendance.fromFirestore(e))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  static Future<Attendance?> checkAttendance(String studentId,
      {DateTime? date}) async {
    try {
      final dateTime = date ?? DateTime.now();
      final today = DateTime(dateTime.year, dateTime.month, dateTime.day)
          .toIso8601String();
      final attendance = await db
          .from('attendance')
          .select()
          .eq('student_id', studentId)
          .eq('date', today)
          .limit(1);
      if (attendance.isEmpty) {
        return null;
      }
      return Attendance.fromFirestore(attendance.first);
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> addAttendance(String studentId, String teacherId,
      DateTime date, AttendanceStatus status) async {
    try {
      final isExist = await checkAttendance(studentId, date: date);
      if (isExist != null) {
        await removeAttendance(isExist.id);
      }

      final id = const UuidV7().generate();
      date = date.add(const Duration(hours: 1));
      final attendance = Attendance(
          id: id,
          studentId: studentId,
          teacherId: teacherId,
          date: date,
          status: status);
      await db.from('attendance').insert(attendance.toJson());
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> removeAttendance(String id) async {
    try {
      await db.from('attendance').delete().match({'id': id});
    } catch (e) {
      rethrow;
    }
  }
}
