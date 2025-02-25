import 'package:equatable/equatable.dart';

class StorageFile extends Equatable {
  final String name;
  final String schoolId;
  final String id;
  final DateTime createdAt;

  const StorageFile(
      {required this.name,
      required this.schoolId,
      required this.id,
      required this.createdAt});

  @override
  List<Object?> get props => [name, schoolId, id, createdAt];

  factory StorageFile.fromJson(Map<String, dynamic> json) => StorageFile(
      name: json['name'],
      schoolId: json['school_id'],
      id: json['id'],
      createdAt: DateTime.parse(json['created_at']));

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'school_id': schoolId,
      'id': id,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
