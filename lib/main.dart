import 'package:al_furqan/application/activation/activation_cubit.dart';
import 'package:al_furqan/application/auth/auth_cubit.dart';
import 'package:al_furqan/application/middleware/auth_checker.dart';
import 'package:al_furqan/application/school/cubit/school_cubit.dart';
import 'package:al_furqan/application/student/crud/student_cubit.dart';
import 'package:al_furqan/application/theme/theme_cubit.dart';
import 'package:al_furqan/firebase_options.dart';
import 'package:al_furqan/utils.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:intl/intl_standalone.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
      url: "https://enyekfehjiqctvumxqck.supabase.co",
      anonKey:
          "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVueWVrZmVoamlxY3R2dW14cWNrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzkxOTE0ODUsImV4cCI6MjA1NDc2NzQ4NX0.aFbzwvoVQnlM92kfRWDO28p9vu9bYRb_17m5FR8isJw");

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: await getApplicationDocumentsDirectory(),
  );
  if (!kDebugMode) {
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };
    // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }
  await findSystemLocale();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => AuthCubit()..watchAuthState()),
          BlocProvider(create: (context) => ThemeCubit()),
          BlocProvider(create: (context) => StudentCubit()),
          BlocProvider(create: (context) => SchoolCubit()),
          BlocProvider(create: (context) => ActivationCubit()),
        ],
        child: BlocConsumer<ThemeCubit, ThemeState>(
          listener: (context, state) {},
          builder: (context, state) {
            return MaterialApp(
                title: 'Masjid Al-Sunnah',
                locale: const Locale('ar', 'DZ'),
                supportedLocales: const [Locale('ar', 'DZ')],
                localizationsDelegates: const [
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                  AppLocalizations.delegate
                ],
                debugShowCheckedModeBanner: false,
                themeMode: ThemeMode.system,
                darkTheme: FlexThemeData.dark(scheme: FlexScheme.tealM3),
                theme: state is ThemeDark
                    ? FlexThemeData.dark(scheme: FlexScheme.tealM3)
                    : FlexThemeData.light(scheme: FlexScheme.greenM3),
                home: Builder(builder: (context) => const AuthChecker()));
          },
        ));
  }
}
