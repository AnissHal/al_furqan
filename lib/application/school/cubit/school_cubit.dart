import 'package:al_furqan/application/services/asset_service.dart';
import 'package:al_furqan/application/services/school_service.dart';
import 'package:al_furqan/models/schools.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:image_picker/image_picker.dart';

part 'school_state.dart';

class SchoolCubit extends HydratedCubit<SchoolState> {
  SchoolCubit() : super(SchoolInitial());

  Future<void> loadSchool(String id) async {
    if (state is SchoolLoaded) return;
    final school = await SchoolService.fetchSchool(id);
    emit(SchoolLoaded(school: school));
  }

  Future<void> refreshSchool(String id) async {
    final school = await SchoolService.fetchSchool(id);
    CachedNetworkImage.evictFromCache('logo');
    emit(SchoolLoaded(school: school));
  }

  void resetState() {
    CachedNetworkImage.evictFromCache('logo');
    emit(SchoolInitial());
  }

  void updateSchoolImage(XFile image) {
    if (state is! SchoolLoaded) return;
    final s = state as SchoolLoaded;
    try {
      AssetService.updateSchoolAvatar(image, s.school).then((_) {
        refreshSchool(s.school.id);
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateSchool({String? name, String? address}) async {
    if (state is! SchoolLoaded) return;
    final s = state as SchoolLoaded;
    try {
      await SchoolService.updateSchool(
              schoolId: s.school.id, name: name, address: address)
          .then((_) {
        refreshSchool(s.school.id);
      });
    } catch (e) {
      rethrow;
    }
  }

  void deleteSchoolImage() {
    if (state is! SchoolLoaded) return;
    final s = state as SchoolLoaded;
    try {
      AssetService.deleteSchoolAvatar(s.school).then((_) {
        refreshSchool(s.school.id);
      });
    } catch (e) {
      rethrow;
    }
  }

  @override
  SchoolState? fromJson(Map<String, dynamic> json) {
    try {
      return SchoolLoaded(school: Schools.fromJson(json['school']));
    } catch (e) {
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(SchoolState state) {
    if (state is SchoolLoaded) {
      return {'school': state.school.toCubitJson()};
    }
    return null;
  }
}
