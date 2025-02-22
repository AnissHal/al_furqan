import 'package:equatable/equatable.dart';

class Students extends Equatable {
  final String id;
  final String fullName;
  final String? image;
  final String schoolId;
  final String teacherId;
  final bool requested;
  final DateTime createdAt;

  const Students(
      {required this.id,
      required this.fullName,
      required this.image,
      required this.schoolId,
      required this.teacherId,
      required this.requested,
      required this.createdAt});

  @override
  List<Object?> get props =>
      [id, fullName, image, schoolId, teacherId, requested, createdAt];

  factory Students.fromJson(Map<String, dynamic> json) => Students(
      id: json['id'],
      fullName: json['full_name'],
      image: json['image'],
      schoolId: json['school_id'],
      teacherId: json['teacher_id'],
      requested: json['requested'],
      createdAt: DateTime.parse(json['created_at']));

  Map<String, dynamic> toJson() => {
        'id': id,
        'full_name': fullName,
        'image': image,
        'school_id': schoolId,
        'teacher_id': teacherId,
        'requested': requested,
      };
}
