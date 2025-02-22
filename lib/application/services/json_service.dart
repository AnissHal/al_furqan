import 'dart:convert';

import 'package:al_furqan/models/mutn.dart';
import 'package:al_furqan/models/quran_status.dart';
import 'package:flutter/services.dart';

class JsonService {
  // load json file from asset

  static Future<List<QuranStatus>> loadQuranStatus() async {
    final data = await rootBundle.loadString('assets/surah.json');
    final json = jsonDecode(data) as List;
    return json.map((e) => QuranStatus.fromJson(e)).toList();
  }

  static Future<List<Mutn>> loadMutun() async {
    final data = await rootBundle.loadString('assets/mutun.json');
    final json = jsonDecode(data) as List;
    return json.map((e) => Mutn.fromJson(e)).toList();
  }
}
