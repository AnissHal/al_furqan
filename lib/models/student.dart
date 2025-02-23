import 'package:al_furqan/application/enums/encouragement.dart';
import 'package:al_furqan/models/users.dart';
import 'package:equatable/equatable.dart';

class Student extends Equatable {
  final String id;
  final String fullName;
  final int age;
  final String? image;
  final String phone;
  final String? parentId;
  final String schoolId;
  final String teacherId;
  final Users? parent;
  final Users? teacher;
  final bool? requested;
  final Encouragement? encouragement;
  final Behaviour? behaviour;
  final double? mark;
  final DateTime createdAt;

  const Student({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.age,
    this.image,
    this.parent,
    this.teacher,
    this.encouragement,
    this.behaviour,
    this.mark,
    required this.schoolId,
    this.parentId,
    required this.teacherId,
    this.requested,
    required this.createdAt,
  });

  factory Student.fromJson(Map<String, dynamic> json, {String? id}) {
    return Student(
      id: id ?? json['id'],
      fullName: json['full_name'],
      phone: json['phone'],
      teacherId: json['teacher_id'],
      age: json['age'],
      image: json['image'],
      behaviour: json['behaviour'] != null
          ? Behaviour.fromString(json['behaviour'])
          : null,
      encouragement: json['encouragement'] != null
          ? Encouragement.fromString(json['encouragement'])
          : null,
      mark: json['mark'].runtimeType == int
          ? (json['mark'] as int).toDouble()
          : json['mark'],
      schoolId: json['school_id'],
      requested: json['requested'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Student copyWith({
    String? id,
    String? fullName,
    String? phone,
    String? parentId,
    String? teacherId,
    String? schoolId,
    int? age,
    String? image,
    Users? parent,
    Users? teacher,
    bool? requested,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool updateImage = false,
  }) {
    return Student(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      parentId: parentId ?? this.parentId,
      teacherId: teacherId ?? this.teacherId,
      age: age ?? this.age,
      image: updateImage ? image : this.image,
      parent: parent ?? this.parent,
      teacher: teacher ?? this.teacher,
      schoolId: schoolId ?? this.schoolId,
      requested: requested ?? this.requested,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        age,
        phone,
        createdAt,
        teacherId,
        parentId,
        requested,
        image,
        fullName,
        schoolId,
        parent,
        teacher,
      ];

  Map<String, dynamic> toJson() => {
        'id': id,
        'age': age,
        'full_name': fullName,
        'phone': phone,
        'image': image,
        'requested': requested ?? false,
        'teacher_id': teacherId,
        'school_id': schoolId,
        'created_at': createdAt.toIso8601String(),
      };
}
