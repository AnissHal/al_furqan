import 'package:al_furqan/models/progress.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProgressService {
  static final db = Supabase.instance.client;

  static Future<void> addProgress(Progress progress) async {
    try {
      await db
          .from('progression')
          .insert(progress.toJson())
          .match({'student_id': progress.studentId});
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> updateProgress(Progress progress) async {
    try {
      await db
          .from('progression')
          .update(progress.toJson())
          .match({'id': progress.id!});
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<Progress>> getProgress(String studentId) async {
    try {
      return (await db.from('progression').select().eq('student_id', studentId))
          .map((e) => Progress.fromJson(e))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  static Future deleteProgress(int progressId) async {
    try {
      await db.from('progression').delete().match({'id': progressId});
    } catch (e) {
      rethrow;
    }
  }
}
