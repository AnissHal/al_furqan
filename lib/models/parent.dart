import 'package:equatable/equatable.dart';

class Parent extends Equatable {
  final String id;
  final String username;
  final String name;
  final String phone;
  final String address;
  final String password;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Parent({
    required this.id,
    required this.username,
    required this.name,
    required this.phone,
    required this.address,
    required this.password,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Parent.fromJson(Map<String, dynamic> json, {String? id}) => Parent(
        id: id ?? json['id'],
        username: json['username'],
        name: json['name'],
        phone: json['phone'],
        address: json['address'],
        password: json['password'],
        createdAt: DateTime.parse(json['created_at']),
        updatedAt: DateTime.parse(json['updated_at']),
      );

  @override
  List<Object?> get props =>
      [id, username, name, phone, address, createdAt, updatedAt, password];

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'name': name,
        'phone': phone,
        'address': address,
        'password': password,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}
