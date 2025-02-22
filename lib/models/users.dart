import 'package:equatable/equatable.dart';

enum UserRole {
  admin,
  student,
  teacher,
  parent;

  @override
  String toString() {
    return switch (this) {
      admin => 'admin',
      student => 'student',
      teacher => 'teacher',
      parent => 'parent'
    };
  }

  static UserRole fromString(String role) {
    switch (role) {
      case 'admin':
        return UserRole.admin;
      case 'student':
        return UserRole.student;
      case 'teacher':
        return UserRole.teacher;
      case 'parent':
        return UserRole.parent;
      default:
        return UserRole.parent;
    }
  }
}

class Users extends Equatable {
  final String id;
  final String fullName;
  final String username;
  final String? phone;
  final String? image;
  final String schoolId;
  final UserRole role;
  final DateTime? createdAt;

  const Users(
      {required this.id,
      required this.fullName,
      required this.username,
      required this.phone,
      required this.image,
      required this.schoolId,
      this.createdAt,
      required this.role});

  @override
  List<Object?> get props =>
      [id, fullName, username, phone, image, schoolId, role, createdAt];

  factory Users.fromJson(Map<String, dynamic> json) => Users(
      id: json['id'],
      fullName: json['full_name'],
      username: json['username'],
      phone: json['phone'],
      image: json['image'],
      schoolId: json['school_id'],
      createdAt: DateTime.parse(json['created_at']),
      role: UserRole.fromString(json['role']));

  Map<String, dynamic> toJson() => {
        'id': id,
        'full_name': fullName,
        'username': username,
        'phone': phone,
        'image': image,
        'school_id': schoolId,
        'role': role.toString()
      };

  Map<String, dynamic> toCubitJson() => {
        'id': id,
        'full_name': fullName,
        'username': username,
        'phone': phone,
        'image': image,
        'school_id': schoolId,
        'role': role.toString(),
        'created_at': createdAt!.toIso8601String()
      };

  factory Users.empty() => const Users(
      id: '',
      fullName: '',
      username: '',
      phone: '',
      image: '',
      schoolId: '',
      role: UserRole.student);
}
