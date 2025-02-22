import 'package:al_furqan/models/mutn.dart';
import 'package:al_furqan/models/quran_status.dart';
import 'package:equatable/equatable.dart';

enum CourseType {
  quran,
  mutn;

  @override
  String toString() =>
      switch (this) { CourseType.mutn => 'mutn', CourseType.quran => 'quran' };

  static CourseType fromString(String course) => switch (course) {
        "mutn" => CourseType.mutn,
        "quran" => CourseType.quran,
        _ => CourseType.quran
      };
}

class Progress extends Equatable {
  final int? id;
  final String studentId;
  final CourseType course;
  final int index;
  final int count;
  final String title;
  final int from;
  final int to;
  final ItemType type;
  final double mark;
  final DateTime? createdAt;

  const Progress(
      {this.id,
      required this.studentId,
      required this.course,
      required this.index,
      required this.count,
      required this.title,
      required this.from,
      required this.to,
      required this.type,
      required this.mark,
      this.createdAt});

  @override
  List<Object?> get props => [
        id,
        studentId,
        createdAt,
        index,
        count,
        title,
        mark,
        from,
        to,
        type,
        course
      ];

  Progress copyWith({
    String? id,
    String? studentId,
    int? index,
    int? count,
    String? title,
    int? from,
    int? to,
    ItemType? type,
    CourseType? course,
    double? mark,
    DateTime? createdAt,
  }) {
    return Progress(
      studentId: studentId ?? this.studentId,
      createdAt: createdAt ?? this.createdAt,
      to: to ?? this.to,
      from: from ?? this.from,
      title: title ?? this.title,
      course: course ?? this.course,
      type: type ?? this.type,
      index: index ?? this.index,
      count: count ?? this.count,
      mark: mark ?? this.mark,
    );
  }

  Map<String, dynamic> toJson() {
    final today = DateTime.now();
    return {
      'student_id': studentId,
      'to': to,
      'from': from,
      'title': title,
      'course': course.toString(),
      'type': type.toString(),
      'index': index,
      'count': count,
      'mark': mark,
      'created_at': createdAt != null
          ? DateTime(createdAt!.year, createdAt!.month, createdAt!.day)
              .toIso8601String()
          : DateTime(today.year, today.month, today.day).toIso8601String()
    };
  }

  QuranItem getQuranItem() => QuranItem(
      fromQuranStatus:
          QuranStatus(count: count, index: index.toString(), titleAr: title),
      note: mark,
      fromAyah: from,
      toAyah: to,
      type: type);

  MutnItem getMutnItem() => MutnItem(
      fromMutn: Mutn(count: count, index: index, titleAr: title),
      note: mark,
      from: from,
      to: to,
      type: type);

  factory Progress.fromJson(Map<String, dynamic> json) => Progress(
        id: json['id'],
        studentId: json['student_id'] as String,
        to: json['to'],
        from: json['from'],
        title: json['title'],
        course: CourseType.fromString(json['course']),
        type: ItemType.fromString(json['type']),
        index: json['index'],
        count: json['count'],
        mark: json['mark'].runtimeType == int
            ? (json['mark'] as int).toDouble()
            : json['mark'],
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}
