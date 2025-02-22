import 'package:equatable/equatable.dart';

class Teacher extends Equatable {
  final String id;
  final String username;
  final String name;
  final String phone;
  final String password;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Teacher(
      {required this.id,
      required this.username,
      required this.name,
      required this.phone,
      required this.password,
      required this.createdAt,
      required this.updatedAt});

  factory Teacher.fromJson(Map<String, dynamic> json, {String? id}) {
    return Teacher(
      id: id ?? json['id'],
      username: json['username'],
      name: json['name'],
      phone: json['phone'],
      password: json['password'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  @override
  List<Object?> get props =>
      [id, username, name, phone, createdAt, updatedAt, password];

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'name': name,
        'phone': phone,
        'password': password,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String()
      };
}
