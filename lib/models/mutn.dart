import 'package:al_furqan/models/quran_status.dart';
import 'package:equatable/equatable.dart';

class Mutn extends Equatable {
  final int index;
  final String titleAr;
  final int count;

  const Mutn({required this.index, required this.titleAr, required this.count});

  factory Mutn.fromJson(Map<String, dynamic> json) {
    return Mutn(
      index: json['index'],
      titleAr: json['titleAr'],
      count: json['count'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'index': index,
      'titleAr': titleAr,
      'count': count,
    };
  }

  @override
  List<Object?> get props => [index, titleAr, count];
}

class MutnItem extends Equatable {
  final Mutn fromMutn;
  // final Mutn toMutn;
  final double note;
  final int from;
  final int to;
  final ItemType type;

  const MutnItem(
      {required this.fromMutn,
      // required this.toMutn,
      required this.note,
      required this.from,
      required this.to,
      required this.type});

  @override
  List<Object?> get props => [
        fromMutn,
        // toMutn,
        note, type, from, to
      ];

  factory MutnItem.fromJson(Map<String, dynamic> json) {
    return MutnItem(
      fromMutn: Mutn.fromJson(json['fromMutn']),
      // toMutn: Mutn.fromJson(json['toMutn']),
      from: json['from'],
      to: json['to'],
      note: json['note'],
      type: ItemType.fromString(json['type']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      'from': from,
      'to': to,
      'fromMutn': fromMutn.toJson(),
      // 'toMutn': toMutn.toJson(),
      'note': note,
    };
  }
}
