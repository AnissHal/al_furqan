import 'package:al_furqan/models/parent.dart';
import 'package:al_furqan/models/student.dart';
import 'package:al_furqan/models/users.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ParentService {
  static final db = Supabase.instance.client;

  static Future<void> updateParent(Parent parent) async {
    try {
      await db.from("parents").update(parent.toJson());
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> removeParent(String id) async {
    try {
      await db.from("parents").delete().match({'id': id});
    } catch (e) {
      rethrow;
    }
  }

  static Future<int> countParentsBySchool(String id) async {
    try {
      return (await db.from('users').select().match(
              {'school_id': id, 'role': UserRole.parent.toString()}).count())
          .count;
    } catch (e) {
      rethrow;
    }
  }

  static Future<Users> getParentByStudent(String id) async {
    try {
      final parentId = (await db
          .from('parents_students')
          .select()
          .match({'student_id': id}).single())['parent_id'];
      return db
          .from('users')
          .select()
          .match({'id': parentId})
          .single()
          .then((value) => Users.fromJson(value));
    } catch (e) {
      rethrow;
    }
  }

  static Future changeStudentParent(Student student, Users parent) async {
    try {
      await db
          .from('parents_students')
          .update({'parent_id': parent.id}).match({'student_id': student.id});
    } catch (e) {
      rethrow;
    }
  }

  static Stream<List<Users>> getParents({required String schoolId}) {
    try {
      return db
          .from('users')
          .stream(primaryKey: ['id'])
          .eq('school_id', schoolId)
          .map((event) => event.map((e) => Users.fromJson(e)).toList());
    } catch (e) {
      rethrow;
    }
  }

  static Future<bool> doesParentExist(String username) async {
    try {
      final doc = await db
          .from('users')
          .select('*')
          .match({'username': username})
          .limit(1)
          .single();

      return doc.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  static Future<int> countStudentByParent(String id) async {
    try {
      final doc = await db
          .from('students')
          .select('*')
          .match({'parent_id': id}).count();

      return doc.count;
    } catch (e) {
      return 0;
    }
  }

  static Future<Parent?> find(String username) async {
    try {
      final doc =
          await db.from('parents').select().eq('username', username).single();

      return Parent.fromJson(doc);
    } catch (e) {
      return null;
    }
  }

  static Future<bool> checkPassword(Parent parent, String password) async {
    try {
      final doc =
          await db.from('parents').select().match({'id': parent.id}).single();
      return doc['password'] == password;
    } catch (e) {
      return false;
    }
  }
}
