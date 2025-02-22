import 'package:equatable/equatable.dart';

enum AttendanceStatus {
  present,
  absent,
  excused,
  late;

  static AttendanceStatus fromString(String status) => switch (status) {
        'present' => AttendanceStatus.present,
        'absent' => AttendanceStatus.absent,
        'excused' => AttendanceStatus.excused,
        'late' => AttendanceStatus.late,
        _ => AttendanceStatus.present
      };

  @override
  String toString() => switch (this) {
        AttendanceStatus.present => 'present',
        AttendanceStatus.absent => 'absent',
        AttendanceStatus.excused => 'excused',
        AttendanceStatus.late => 'late'
      };
}

class Attendance extends Equatable {
  final String id;
  final String studentId;
  final String teacherId;
  final DateTime date;
  final AttendanceStatus status;

  const Attendance({
    required this.id,
    required this.studentId,
    required this.teacherId,
    required this.date,
    required this.status,
  });

  factory Attendance.fromFirestore(Map<String, dynamic> json, {String? id}) =>
      // timestamp firestore to date
      Attendance(
        id: id ?? json['id'],
        studentId: json['student_id'],
        teacherId: json['teacher_id'],
        date: DateTime.parse(json['date']),
        status: AttendanceStatus.fromString(json['status']),
      );

  @override
  List<Object?> get props => [id, studentId, teacherId, date, status];

  Map<String, dynamic> toJson() => {
        'id': id,
        'student_id': studentId,
        'teacher_id': teacherId,
        'date': date.toIso8601String(),
        'status': status.toString(),
      };

  Map<String, dynamic> toFirestore() => {
        'id': id,
        'student_id': studentId,
        'teacher_id': teacherId,
        'date': DateTime(date.year, date.month, date.day),
        'status': status.toString(),
      };
}
