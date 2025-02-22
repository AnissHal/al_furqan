import 'dart:async';

import 'package:al_furqan/application/services/asset_service.dart';
import 'package:al_furqan/application/services/users_service.dart';
import 'package:al_furqan/models/users.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

part 'parent_manage_state.dart';

class ParentManageCubit extends Cubit<ParentManageState> {
  ParentManageCubit() : super(ParentManageInitial());

  StreamSubscription? parentStream;
  void loadParent(Users parent) {
    parentStream = UsersService.watchUser(parent.id).listen((e) {
      if (e == null) return;
      emit(ParentManageLoaded(parent: e));
    });
  }

  Future<void> removeParentImage() async {
    if (state is! ParentManageLoaded) return;
    final s = state as ParentManageLoaded;
    await AssetService.removeAvatar(
        s.parent.id, s.parent.image!, s.parent.schoolId);
  }

  Future<String?> updateParentImage(XFile avatar) async {
    if (state is! ParentManageLoaded) return null;
    final s = state as ParentManageLoaded;
    return await AssetService.updateAvatar(
        avatar, s.parent.image, s.parent.id, s.parent.schoolId, false);
  }

  @override
  Future<void> close() {
    parentStream?.cancel();
    return super.close();
  }
}
