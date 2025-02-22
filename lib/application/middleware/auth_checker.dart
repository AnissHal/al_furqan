import 'package:al_furqan/application/activation/activation_cubit.dart';
import 'package:al_furqan/application/auth/auth_cubit.dart';
import 'package:al_furqan/screens/admin/dashboard.dart';
import 'package:al_furqan/screens/homescreen.dart';
import 'package:al_furqan/screens/login_screen.dart';
import 'package:al_furqan/screens/teacher/register_screen.dart';
import 'package:al_furqan/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthChecker extends StatelessWidget {
  const AuthChecker({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: isTest
            ? BlocBuilder<ActivationCubit, ActivationState>(
                builder: (context, state) {
                  if (state is ActivationInvalid) {
                    return Scaffold(
                      backgroundColor: Colors.white,
                      body: Center(
                          child: Text(
                        context.loc.trial_version_expired,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Colors.red,
                            fontSize: 24,
                            fontWeight: FontWeight.bold),
                      )),
                    );
                  }
                  return BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, state) {
                      if (state is UserAuthenticated) {
                        return const AdminDashboardGrid();
                      } else {
                        return const LoginScreen();
                      }
                    },
                  );
                },
              )
            : BlocBuilder<AuthCubit, AuthState>(builder: (context, state) {
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
