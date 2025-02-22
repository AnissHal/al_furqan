import 'package:al_furqan/models/schools.dart';
import 'package:al_furqan/models/users.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SchoolService {
  static final db = Supabase.instance.client;

  static Future<Schools> fetchSchool(String schoolId) async {
    try {
      final school = await db
          .from('schools')
          .select()
          .eq('id', schoolId)
          .limit(1)
          .single();

      final s = Schools.fromJson(school);
      return s;
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> updateSchool(
      {required String schoolId, String? name, String? address}) async {
    try {
      final updateData = {};
      if (name != null) {
        updateData['name'] = name;
      }
      if (address != null) {
        updateData['address'] = address;
      }
      if (updateData.isEmpty) return;
      await db.from('schools').update(updateData).match({'id': schoolId});
    } catch (e) {
      rethrow;
    }
  }

  static Future<Users> fetchSchoolAdmin(String schoolId) async {
    try {
      final school = await db
          .from('users')
          .select()
          .eq('school_id', schoolId)
          .eq('role', UserRole.admin.toString())
          .limit(1)
          .single();

      final s = Users.fromJson(school);
      return s;
    } catch (e) {
      rethrow;
    }
  }
}
