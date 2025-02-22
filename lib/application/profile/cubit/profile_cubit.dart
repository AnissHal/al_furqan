import 'package:al_furqan/application/services/asset_service.dart';
import 'package:al_furqan/application/services/users_service.dart';
import 'package:al_furqan/models/users.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(ProfileInitial());

  void loadProfile(Users user) async {
    emit(ProfileInitial());
    UsersService.fetchUser(user.id).then((e) {
      emit(ProfileLoaded(user: e));
    });
  }

  Future<void> removeProfileImage() async {
    if (state is! ProfileLoaded) return;
    final s = state as ProfileLoaded;
    await AssetService.removeAvatar(s.user.id, s.user.image!, s.user.schoolId);
  }

  Future<String?> updateProfileImage(XFile avatar) async {
    if (state is! ProfileLoaded) return null;
    final s = state as ProfileLoaded;
    return await AssetService.updateAvatar(
        avatar, s.user.image, s.user.id, s.user.schoolId, false);
  }

  static Future<void> updatePassword(String userId, String newPassword) async {
    await UsersService.modifyUserThroughEdge(
        userId: userId, password: newPassword);
  }
}
