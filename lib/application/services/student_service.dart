import 'dart:io';

import 'package:al_furqan/application/enums/encouragement.dart';
import 'package:al_furqan/application/services/asset_service.dart';
import 'package:al_furqan/application/services/parent_service.dart';
import 'package:al_furqan/models/student.dart';
import 'package:al_furqan/models/users.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/v7.dart';

class StudentService {
  static final db = Supabase.instance.client;

  static final storage = Supabase.instance.client.storage.from('pictures');

  static Future<String> addStudent(
      {required String fullName,
      required int age,
      required Users parent,
      required Users teacher,
      String phone = '',
      XFile? image}) async {
    try {
      final now = DateTime.now();
      final id = const UuidV7().generate();
      final student = Student(
        id: id,
        fullName: fullName,
        phone: phone,
        age: age,
        schoolId: teacher.schoolId,
        requested: false,
        teacherId: teacher.id,
        createdAt: now,
      );
      await db.from('students').insert(student.toJson());
      await db
          .from('parents_students')
          .insert({'student_id': id, 'parent_id': parent.id});

      if (image != null) {
        await AssetService.uploadAvatar(image, id, teacher.schoolId);
      }
      return id;
    } catch (e) {
      rethrow;
    }
  }

  static Future<int> countStudentsBySchool(String id) async {
    try {
      return (await db
              .from('students')
              .select()
              .match({'school_id': id}).count())
          .count;
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> toggleStudentRequest(String id, bool? current) async {
    try {
      bool set;
      if (current == null) {
        set = false;
      } else {
        set = !current;
      }
      await db.from('students').update({'requested': set}).eq('id', id);
    } catch (e) {
      rethrow;
    }
  }

  static Future<bool> removeStudent(String id) async {
    try {
      await db.from('students').delete().match({'id': id});
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<String> uploadStudentImage(String id, String path) async {
    try {
      final file = File(path);
      final fileName = '${DateTime.timestamp()}_$id.jpg';
      await storage.upload(fileName, file,
          fileOptions: const FileOptions(cacheControl: '3600'));
      final publicUrl = storage.getPublicUrl(fileName);
      await db.from('students').update({
        'image_name': fileName,
        'image': publicUrl,
        "updated_at": DateTime.now().toIso8601String()
      }).eq('id', id);
      return publicUrl;
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> removeStudentImage(String id, String imageName) async {
    try {
      await storage.remove([imageName]);
      await db.from('students').update({
        'image_name': null,
        'image': null,
        "updatedAt": DateTime.now().toIso8601String()
      }).eq('id', id);
    } catch (e) {
      rethrow;
    }
  }

  static Future<String> updateStudent(
      {required String fullName,
      required int age,
      required Users parent,
      required Users teacher,
      String phone = '',
      required Student student,
      XFile? image}) async {
    try {
      final now = DateTime.now();
      final nstudent = Student(
        id: student.id,
        fullName: fullName,
        phone: phone,
        age: age,
        schoolId: teacher.schoolId,
        parent: parent,
        teacherId: teacher.id,
        createdAt: now,
      );

      await db.from('students').update({
        ...nstudent.toJson(),
      }).match({'id': student.id});

      if (image != null) {
        String file;
        if (student.image == null) {
          file = await AssetService.uploadStudentAvatar(
              image, student.id, teacher.schoolId);
        } else {
          file = await AssetService.updateAvatar(
              image, student.image!, student.id, teacher.schoolId, true);
        }
        CachedNetworkImage.evictFromCache(file);
      }

      if (parent.id != student.parentId) {
        await ParentService.changeStudentParent(student, parent);
      }
      CachedNetworkImage.evictFromCache(
          AssetService.composeStudentImageURL(student));
      return student.id;
    } catch (e) {
      rethrow;
    }
  }

  static Future<Student?> find(String id) async {
    try {
      final doc = await db.from('students').select().eq('id', id).single();

      return Student.fromJson(doc);
    } catch (e) {
      return null;
    }
  }

  static Stream<Student?> watchStudent(String id) {
    try {
      return db
          .from('students')
          .stream(primaryKey: ['id'])
          .eq('id', id)
          .map((e) => e.isEmpty ? null : Student.fromJson(e.first));
    } catch (e) {
      rethrow;
    }
  }

  static Stream watchStudents() {
    try {
      return db.from('students').stream(primaryKey: ['id']).order('created_at');
    } catch (e) {
      rethrow;
    }
  }

  static Stream<List<Student>> watchStudentsByTeacher(String id) {
    try {
      return db
          .from('students')
          .stream(primaryKey: ['id'])
          .eq('teacher_id', id)
          .map((event) => event.map((e) => Student.fromJson(e)).toList());
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<Student>> getStudentsByTeacher(String id) async {
    try {
      final req = await db.from('students').select().eq('teacher_id', id);

      return req.map((e) => Student.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<Student>> getStudents() async {
    try {
      final req = await db.from('students').select();

      return req.map((e) => Student.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  static Stream<List<Student>> watchStudentsByAdmin(String id) {
    try {
      return db
          .from('students')
          .stream(primaryKey: ['id'])
          .eq('school_id', id)
          .map((event) => event.map((e) => Student.fromJson(e)).toList());
    } catch (e) {
      rethrow;
    }
  }

  static Future updateStudentMarkandObservation(
      {required String id,
      Encouragement? encouragement,
      Behaviour? behaviour,
      double? mark}) async {
    try {
      await db.from('students').update({
        'mark': mark,
        'encouragement': encouragement?.toString(),
        'behaviour': behaviour?.toString(),
      }).eq('id', id);
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<Student>> getStudentsByParent(String id) async {
    try {
      final ids = await db
          .from('parents_students')
          .select('student_id')
          .eq('parent_id', id);
      final List<Student> students = [];
      await Future.wait(ids.map((e) async {
        final stu = await db
            .from('students')
            .select()
            .match({'id': e['student_id']}).single();
        students.add(Student.fromJson(stu));
      }));
      return students;
    } catch (e) {
      rethrow;
    }
  }
}
