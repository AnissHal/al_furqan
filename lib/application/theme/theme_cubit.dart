import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

part 'theme_state.dart';

class ThemeCubit extends HydratedCubit<ThemeState> {
  ThemeCubit() : super(ThemeLight());

  void toggleTheme() {
    if (state is ThemeLight) {
      emit(ThemeDark());
    } else {
      emit(ThemeLight());
    }
  }

  @override
  ThemeState? fromJson(Map<String, dynamic> json) {
    if (json['theme'] == 'light') {
      return ThemeLight();
    } else {
      return ThemeDark();
    }
  }

  @override
  Map<String, dynamic>? toJson(ThemeState state) {
    if (state is ThemeLight) {
      return {'theme': 'light'};
    } else {
      return {'theme': 'dark'};
    }
  }
}
