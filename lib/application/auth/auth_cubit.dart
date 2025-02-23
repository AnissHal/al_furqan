import 'package:al_furqan/application/school/cubit/school_cubit.dart';
import 'package:al_furqan/application/services/users_service.dart';
import 'package:al_furqan/models/parent.dart';
import 'package:al_furqan/models/users.dart';
import 'package:al_furqan/utils.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/v4.dart';

part 'auth_state.dart';

enum AuthError {
  wrongPassword,
  notAuthenticated,
  wrongUsername,
  usernameExists,
  userNotFound,
  unknown;

  String translate(BuildContext context) => switch (this) {
        AuthError.wrongPassword => context.loc.wrong_password,
        AuthError.wrongUsername => context.loc.wrong_username,
        AuthError.usernameExists => context.loc.username, // TODO: Translate
        AuthError.userNotFound => context.loc.user_not_found,
        _ => context.loc.unknown_error
      };
}

class AuthCubit extends HydratedCubit<AuthState> {
  AuthCubit() : super(AuthNotAuthenticated(DateTime.timestamp().toString()));
  Future<void> logout(BuildContext context) async {
    context.read<SchoolCubit>().resetState();
    await Supabase.instance.client.auth.signOut();
    emit(AuthNotAuthenticated(DateTime.timestamp().toString()));
  }

  void emitCurrentState() => emit(state);

  @override
  AuthState? fromJson(Map<String, dynamic> json) {
    try {
      return UserAuthenticated(
          supabaseUser: Supabase.instance.client.auth.currentSession!.user,
          userData: Users.fromJson(json['userData']));
    } catch (e) {
      rethrow;
      return AuthNotAuthenticated(const UuidV4().generate());
    }
  }

  Future<void> login(String username, String password) async {
    // find if teacher or parent and emit authenticated teacher or authenticated parent state
    try {
      final email = await UsersService.emailByUsername(username);
      await Supabase.instance.client.auth
          .signInWithPassword(password: password, email: email);
    } catch (e) {
      // await FirebaseCrashlytics.instance
      //     .recordError(e, StackTrace.current, fatal: true);
      rethrow;
    }
  }

  Future<void> watchAuthState() async {
    Supabase.instance.client.auth.onAuthStateChange.listen((event) async {
      if (event.event == AuthChangeEvent.signedIn ||
          event.event == AuthChangeEvent.initialSession) {
        try {
          if (event.session == null) {
            return;
          }

          // emit(UserAuthenticated(supabaseUser: event.session!.user));
          Future.delayed(const Duration(seconds: 2), () {
            UsersService.fetchUser(event.session!.user.id).then((e) {
              emit(UserAuthenticated(
                  supabaseUser: event.session!.user, userData: e));
            });
          });
        } catch (e) {
          rethrow;
        }
      }
      if (event.event == AuthChangeEvent.signedOut) {
        emit(AuthNotAuthenticated(DateTime.timestamp().toString()));
      }
    });
  }

  Future<void> registerTeacher(Users admin, String fullName, String phone,
      String username, String password, XFile? image) async {
    try {
      if (admin.role != UserRole.admin) {
        throw Exception('Only admin can register teacher');
      }
      // check for username exists
      final schoolId = admin.schoolId;
      final exists = await UsersService.doesUsernameExist(username);
      if (exists) {
        throw Exception('Username already exists');
      }
      await UsersService.createTeacher(
          username, password, phone, schoolId, fullName, image);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> registerParent(Users admin, String fullName, String phone,
      String username, String password, XFile? image) async {
    try {
      if (admin.role != UserRole.admin && admin.role != UserRole.teacher) {
        throw Exception('Only admin or teacher can register parent');
      }
      // check for username exists
      final schoolId = admin.schoolId;
      final exists = await UsersService.doesUsernameExist(username);
      if (exists) {
        throw Exception('Username already exists');
      }
      await UsersService.createParent(
          username, password, phone, schoolId, fullName, image);
    } catch (e) {
      rethrow;
    }
  }

  void goToLoginScreen() {
    emit(AuthUserLogin());
  }

  void goToRegisterScreen() {
    emit(AuthUserCreating());
  }

  Future<void> registerAdmin(String fullName, String phone, String username,
      String password, String schoolId, String? image) async {
    try {
      // // check for username exists
      // final exists = await UsersService.doesUsernameExist(username);
      // if (exists) {
      //   emit(AuthNotAuthenticated(DateTime.timestamp().toString(),
      //       message: AuthError.usernameExists));
      //   return;
      // }
      await UsersService.createAdmin(
          username, password, schoolId, phone, fullName, image);
      // await login(username, password);
    } catch (e) {
      // await FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
      emit(AuthNotAuthenticated(DateTime.timestamp().toString(),
          message: AuthError.unknown));
      rethrow;
    }
  }

  @override
  Map<String, dynamic>? toJson(AuthState state) {
    try {
      switch (state) {
        case UserAuthenticated():
          if (state.userData == null) return null;
          return {'userData': state.userData!.toCubitJson()};
        default:
          return {'notAuthenticated': true};
      }
    } catch (e) {
      FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
    }
    return null;
  }
}
