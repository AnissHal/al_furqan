import 'package:al_furqan/application/auth/auth_cubit.dart';
import 'package:al_furqan/screens/homescreen.dart';
import 'package:al_furqan/screens/login_screen.dart';
import 'package:al_furqan/screens/teacher/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthChecker extends StatelessWidget {
  const AuthChecker({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: BlocBuilder<AuthCubit, AuthState>(builder: (context, state) {
          return switch (state) {
            UserAuthenticated() => const HomeScreen(),
            // AuthParentAuthenticated() => const ParentDashboardScreen(),
            AuthUserLogin() => const LoginScreen(),
            AuthUserCreating() => const RegisterScreen(),
            _ => const LoginScreen(),
          };
        }),
      ),
    );
  }
}
