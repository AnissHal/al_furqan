import 'package:equatable/equatable.dart';

class Schools extends Equatable {
  final String id;
  final String name;
  final String? image;
  final double? lat;
  final double? long;
  final String address;
  final DateTime createdAt;

  const Schools({
    required this.id,
    required this.name,
    this.image,
    this.lat,
    this.long,
    required this.address,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, name, image, address, createdAt, lat, long];

  factory Schools.fromJson(Map<String, dynamic> json) {
    return Schools(
      id: json['id'],
      name: json['name'],
      image: json['image'],
      lat: json['lat'].runtimeType == int
          ? (json['lat'] as int).toDouble()
          : json['lat'],
      long: json['long'].runtimeType == int
          ? (json['long'] as int).toDouble()
          : json['long'],
      address: json['address'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'image': image,
        'lat': lat,
        'long': long,
        'address': address,
      };
  Map<String, dynamic> toCubitJson() => {
        'id': id,
        'name': name,
        'image': image,
        'address': address,
        'lat': lat,
        'long': long,
        'created_at': createdAt.toIso8601String()
      };
}
