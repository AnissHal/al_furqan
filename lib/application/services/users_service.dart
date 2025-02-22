import 'dart:convert';

import 'package:al_furqan/application/services/asset_service.dart';
import 'package:al_furqan/models/users.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UsersService {
  static final db = Supabase.instance.client;

  static Future<Map?> createUserThroughEdge(String email, String password,
      UserRole role, String username, String schoolId, String fullName) async {
    final response = await http.post(
      Uri.parse(
          'https://enyekfehjiqctvumxqck.supabase.co/functions/v1/create-user'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${db.auth.currentSession?.accessToken}',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
        'role': role.toString(),
        'username': username,
        'schoolid': schoolId,
        'fullname': fullName
      }),
    );

    final responseData = jsonDecode(response.body);

    if (response.statusCode == 201) {
      return responseData;
    } else {
      return null;
    }
  }

  static Future<int> countUsersBySchool(String id) async {
    try {
      return (await db
              .from('users')
              .select()
              .match({'school_id': id})
              .or('role.eq.${UserRole.admin.toString()},role.eq.${UserRole.teacher.toString()}')
              .count())
          .count;
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map?> modifyUserThroughEdge(
      {required String userId,
      String? password,
      UserRole? role,
      String? username,
      String? schoolId,
      String? phone,
      String? fullName}) async {
    Map updateData = {};
    if (username != null) {
      final email = '$username@al-furqan.com';
      updateData['email'] = email;
    }
    if (password != null) {
      updateData['password'] = password;
    }
    if (role != null) {
      updateData['role'] = role;
    }

    if (updateData.isNotEmpty) {
      final response = await http.post(
        Uri.parse(
            'https://enyekfehjiqctvumxqck.supabase.co/functions/v1/modify-user'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${db.auth.currentSession?.accessToken}',
        },
        body: jsonEncode({'userId': userId, ...updateData}),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return responseData;
      }
    }
    try {
      updateData = {};
      if (fullName != null) {
        updateData['full_name'] = fullName;
      }
      if (schoolId != null) {
        updateData['school_id'] = schoolId;
      }
      if (phone != null) {
        updateData['phone'] = phone;
      }
      if (updateData.isEmpty) return null;
      await db.from('users').update(updateData).match({'id': userId});
    } catch (e) {
      rethrow;
    }
    return null;
  }

  static Future<Map?> deleteUserThroughEdge(String id) async {
    final response = await http.post(
      Uri.parse(
          'https://enyekfehjiqctvumxqck.supabase.co/functions/v1/delete-user'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${db.auth.currentSession?.accessToken}',
      },
      body: jsonEncode({'userId': id}),
    );

    final responseData = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return responseData;
    } else {
      return null;
    }
  }

  static Future createTeacher(
    String username,
    String password,
    String phone,
    String schoolId,
    String fullName,
    XFile? image,
  ) async {
    try {
      const role = UserRole.teacher;
      final email = '$username@al-furqan.com';
      final res = await createUserThroughEdge(
          email, password, role, username, schoolId, fullName);
      if (res == null) {
        throw Exception("User could not be created");
      }

      if (phone.isNotEmpty) {
        await db.from('users').update({'phone': phone}).match({'email': email});
      }

      if (image != null) {
        await AssetService.uploadAvatar(image, res['id'], res['school_id']);
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future createParent(
    String username,
    String password,
    String phone,
    String schoolId,
    String fullName,
    XFile? image,
  ) async {
    try {
      const role = UserRole.parent;
      final email = '$username@al-furqan.com';
      final res = await createUserThroughEdge(
          email, password, role, username, schoolId, fullName);
      if (res == null) {
        throw Exception("User could not be created");
      }

      if (image != null) {
        await AssetService.uploadAvatar(image, res['id'], res['school_id']);
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<bool> deleteTeacher(
    Users teacher,
  ) async {
    try {
      final res = await deleteUserThroughEdge(teacher.id);
      if (res == null) {
        throw Exception("User could not be created");
      }
      if (teacher.image != null) {
        await AssetService.deleteAvatar(
            teacher.id, teacher.image!, teacher.schoolId);
      }
      return true;
    } catch (e) {
      rethrow;
    }
  }

  static Future<bool> deleteParent(
    Users parent,
  ) async {
    try {
      final res = await deleteUserThroughEdge(parent.id);
      if (res == null) {
        throw Exception("User could not be deleted");
      }
      if (parent.image != null) {
        await AssetService.deleteAvatar(
            parent.id, parent.image!, parent.schoolId);
      }
      return true;
    } catch (e) {
      rethrow;
    }
  }

  static Future<Users> createAdmin(String username, String password,
      String schoolId, String phone, String fullName, String? image) async {
    try {
      const role = UserRole.admin;
      final email = '$username@al-furqan.com';
      final res = await db.auth.signUp(password: password, email: email);
      if (res.user == null) {
        throw Exception("User could not be created");
      }
      final user = Users(
          id: res.user!.id,
          fullName: fullName,
          username: username,
          phone: phone,
          image: '',
          schoolId: schoolId,
          role: role);
      await db.from('users').insert({...user.toJson(), 'email': email});
      return user;
    } catch (e) {
      rethrow;
    }
  }

  static Stream<Users?> watchUser(String id) {
    try {
      return db
          .from('users')
          .stream(primaryKey: ['id'])
          .eq('id', id)
          .map((event) => event.isEmpty ? null : Users.fromJson(event.first));
    } catch (e) {
      rethrow;
    }
  }

  static Future<String> emailByUsername(String username) async {
    try {
      return (await db
          .from('users')
          .select('email')
          .eq('username', username)
          .single())['email'];
    } catch (e) {
      rethrow;
    }
  }

  static Future<Users> fetchUser(String id) async {
    try {
      final res = await db.from('users').select().eq('id', id).single();
      return Users.fromJson(res);
    } catch (e) {
      rethrow;
    }
  }

  static Future<bool> doesUsernameExist(String username) async {
    try {
      final res = await db.from('users').select().match({'username': username});
      return res.isNotEmpty;
    } catch (e) {
      rethrow;
    }
  }
}
