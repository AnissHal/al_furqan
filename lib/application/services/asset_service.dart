import 'dart:io';

import 'package:al_furqan/models/schools.dart';
import 'package:al_furqan/models/student.dart';
import 'package:al_furqan/models/users.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';

class AssetService {
  static final db = Supabase.instance.client;

  static String fetchSchoolImageFromNetwork(Schools school) {
    try {
      // file is in bucket pictures/{schoolId}/logo.{png,jpg}/
      final path = '${school.id}/${school.image}';
      final res = db.storage.from('pictures').getPublicUrl(path);
      return res;
    } catch (e) {
      rethrow;
    }
  }

  static String composeImageURL(Users user) {
    try {
      return db.storage
          .from('pictures')
          .getPublicUrl('${user.schoolId}/avatars/${user.image!}');
    } catch (e) {
      rethrow;
    }
  }

  static String composeStudentImageURL(Student student) {
    try {
      return db.storage
          .from('pictures')
          .getPublicUrl('${student.schoolId}/avatars/${student.image!}');
    } catch (e) {
      rethrow;
    }
  }

  static Future deleteAvatar(String id, String image, String schoolId) {
    try {
      return db.storage.from('pictures').remove(['$schoolId/avatars/$image']);
    } catch (e) {
      rethrow;
    }
  }

  static String getAvatarPublicUrl(String image, String schoolId) {
    try {
      final pathUpload = '$schoolId/avatars/$image';
      return db.storage.from('pictures').getPublicUrl(pathUpload);
    } catch (e) {
      rethrow;
    }
  }

  static Future<String> uploadAvatar(
    XFile avatar,
    String id,
    String schoolId,
  ) async {
    try {
      final file = File(avatar.path);
      final userId = id;
      final adminSchoolId = schoolId;
      final fileName = '$id${p.extension(file.path)}';
      final pathUpload = '$adminSchoolId/avatars/$fileName';
      await db.storage.from('pictures').upload(pathUpload, file,
          fileOptions: const FileOptions(cacheControl: '3600'));
      final publicUrl = db.storage.from('pictures').getPublicUrl(pathUpload);
      await db.from('users').update({
        'image': fileName,
      }).match({'id': userId});
      return publicUrl;
    } catch (e) {
      rethrow;
    }
  }

  static Future<String> uploadSchoolAvatar(
    XFile avatar,
    Schools school,
  ) async {
    try {
      final file = File(avatar.path);
      final fileName = 'logo${p.extension(file.path)}';
      final pathUpload = '${school.id}/$fileName';
      await db.storage.from('pictures').upload(pathUpload, file,
          fileOptions: const FileOptions(cacheControl: '3600'));
      final publicUrl = db.storage.from('pictures').getPublicUrl(pathUpload);
      await db.from('schools').update({
        'image': fileName,
      }).match({'id': school.id});
      return publicUrl;
    } catch (e) {
      rethrow;
    }
  }

  static Future<String> updateSchoolAvatar(
    XFile avatar,
    Schools school,
  ) async {
    try {
      await db.storage
          .from('pictures')
          .remove(['${school.id}/${school.image}']);
      final file = File(avatar.path);
      final fileName = 'logo${p.extension(file.path)}';
      final pathUpload = '${school.id}/$fileName';
      await db.storage.from('pictures').upload(pathUpload, file,
          fileOptions: const FileOptions(cacheControl: '3600'));
      final publicUrl = db.storage.from('pictures').getPublicUrl(pathUpload);
      await db.from('schools').update({
        'image': fileName,
      }).match({'id': school.id});
      CachedNetworkImage.evictFromCache(publicUrl, cacheKey: 'logo');
      return publicUrl;
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> deleteSchoolAvatar(
    Schools school,
  ) async {
    try {
      await db.storage
          .from('pictures')
          .remove(['${school.id}/${school.image}']);
      await db.from('schools').update({
        'image': null,
      }).match({'id': school.id});
      CachedNetworkImage.evictFromCache('', cacheKey: 'logo');
    } catch (e) {
      rethrow;
    }
  }

  static Future<String> uploadStudentAvatar(
    XFile avatar,
    String id,
    String schoolId,
  ) async {
    try {
      final file = File(avatar.path);
      final userId = id;
      final adminSchoolId = schoolId;
      final fileName = '$id${p.extension(file.path)}';
      final pathUpload = '$adminSchoolId/avatars/$fileName';
      await db.storage.from('pictures').upload(pathUpload, file,
          fileOptions: const FileOptions(cacheControl: '3600'));
      final publicUrl = db.storage.from('pictures').getPublicUrl(pathUpload);
      await db.from('students').update({
        'image': fileName,
      }).match({'id': userId});
      return publicUrl;
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> removeAvatar(
    String id,
    String image,
    String schoolId,
  ) async {
    try {
      final userId = id;
      final adminSchoolId = schoolId;
      final pathUpload = '$adminSchoolId/avatars/$image';
      await db.storage.from('pictures').remove([pathUpload]);
      await db.from('users').update({
        'image': null,
      }).match({'id': userId});
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> removeStudentAvatar(
    String id,
    String image,
    String schoolId,
  ) async {
    try {
      final userId = id;
      final adminSchoolId = schoolId;
      final pathUpload = '$adminSchoolId/avatars/$image';
      await db.storage.from('pictures').remove([pathUpload]);
      await db.from('students').update({
        'image': null,
      }).match({'id': userId});
    } catch (e) {
      rethrow;
    }
  }

  static Future<String> updateAvatar(XFile avatar, String? image, String id,
      String schoolId, bool isStudent) async {
    try {
      if (isStudent) {
        if (image != null) {
          await removeStudentAvatar(id, image, schoolId);
        }
        return await uploadStudentAvatar(avatar, id, schoolId);
      }
      if (image != null) {
        await removeAvatar(id, image, schoolId);
      }
      return await uploadAvatar(avatar, id, schoolId);
    } catch (e) {
      rethrow;
    }
  }
}
