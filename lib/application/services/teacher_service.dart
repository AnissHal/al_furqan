import 'package:al_furqan/models/student.dart';
import 'package:al_furqan/models/teacher.dart';
import 'package:al_furqan/models/users.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TeacherService {
  static final db = Supabase.instance.client;

  static Future<Teacher?> find(String username) async {
    try {
      final doc = await db
          .from('users')
          .select()
          .eq('username', username)
          .eq('role', UserRole.teacher.toString())
          .limit(1)
          .single();

      return Teacher.fromJson(doc);
    } catch (e) {
      return null;
    }
  }

  static Future changeStudentTeacher(Student student, Users teacher) async {
    try {
      await db
          .from('students')
          .update({'teacher_id': teacher.id}).match({'id': student.id});
    } catch (e) {
      rethrow;
    }
  }

  static Future<Teacher?> findById(String id) async {
    try {
      final doc = await db
          .from('users')
          .select()
          .eq('id', id)
          .eq('role', UserRole.teacher.toString())
          .limit(1)
          .single();
      return Teacher.fromJson(doc);
    } catch (e) {
      return null;
    }
  }

  static Future<Users> getTeacherByStudent(String id) async {
    try {
      final doc =
          await db.from('users').select().eq('id', id).limit(1).single();
      return Users.fromJson(doc);
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<Users>> getTeachersList(String schoolId) async {
    try {
      final doc = await db
          .from('users')
          .select()
          .neq('role', 'parent')
          .eq('school_id', schoolId);
      return doc.map((e) => Users.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  static Stream<List<Users>> getTeachers(String schoolId) {
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

  static Stream<List<Users>> watchTeacher(Users teacher) {
    try {
      return db
          .from('users')
          .stream(primaryKey: ['id'])
          .eq('id', teacher.id)
          .map((event) => event.map((e) => Users.fromJson(e)).toList());
    } catch (e) {
      rethrow;
    }
  }

  static Future<int> countStudentByTeacher(String id) async {
    try {
      final doc =
          await db.from('students').select().match({'teacher_id': id}).count();
      return doc.count;
    } catch (e) {
      return 0;
    }
  }

  static Future<bool> checkPassword(Teacher teacher, String password) async {
    try {
      final doc = await db
          .from('users')
          .select()
          .eq('id', teacher.id)
          .eq('role', UserRole.teacher.toString())
          .single();
      return doc['password'] == password;
    } catch (e) {
      return false;
    }
  }
}
