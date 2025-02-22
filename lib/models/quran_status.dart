import 'package:equatable/equatable.dart';

class QuranStatus extends Equatable {
  final String titleAr;
  final int count;
  final String index;

  const QuranStatus({
    required this.titleAr,
    required this.count,
    required this.index,
  });

  @override
  List<Object?> get props => [
        titleAr,
        count,
        index,
      ];

  factory QuranStatus.fromJson(Map<String, dynamic> json) {
    return QuranStatus(
      titleAr: json['titleAr'],
      count: json['count'],
      index: json['index'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'titleAr': titleAr,
      'count': count,
      'index': index,
    };
  }
}

enum ItemType {
  revision,
  reading;

  @override
  String toString() {
    switch (this) {
      case ItemType.revision:
        return 'revision';
      case ItemType.reading:
        return 'reading';
    }
  }

  static ItemType fromString(String value) {
    switch (value) {
      case 'revision':
        return ItemType.revision;
      case 'reading':
        return ItemType.reading;
      default:
        return ItemType.reading;
    }
  }
}

class QuranItem extends Equatable {
  final QuranStatus fromQuranStatus;
  // final QuranStatus toQuranStatus;
  final double note;
  final int fromAyah;
  final int toAyah;
  final ItemType type;

  const QuranItem(
      {required this.fromQuranStatus,
      // required this.toQuranStatus,
      required this.note,
      required this.fromAyah,
      required this.toAyah,
      required this.type});

  @override
  List<Object?> get props => [
        fromQuranStatus,
        // toQuranStatus,
        note, type, fromAyah, toAyah
      ];

  factory QuranItem.fromJson(Map<String, dynamic> json) {
    return QuranItem(
      fromQuranStatus: QuranStatus.fromJson(json['fromQuranStatus']),
      // toQuranStatus: QuranStatus.fromJson(json['toQuranStatus']),
      fromAyah: json['fromSurah'],
      toAyah: json['toSurah'],
      note: json['note'],
      type: ItemType.fromString(json['type']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      'fromSurah': fromAyah,
      'toSurah': toAyah,
      'fromQuranStatus': fromQuranStatus.toJson(),
      // 'toQuranStatus': toQuranStatus.toJson(),
      'note': note,
    };
  }
}
