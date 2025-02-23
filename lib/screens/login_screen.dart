import 'package:al_furqan/application/auth/auth_cubit.dart' as auth;
import 'package:al_furqan/utils.dart';
import 'package:al_furqan/widgets/loading_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _form = GlobalKey<FormState>();

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    return BlocListener<auth.AuthCubit, auth.AuthState>(
      listener: (context, state) {
        switch (state) {
          case auth.AuthNotAuthenticated():
            setState(() {
              _loading = false;
            });

          default:
            break;
        }
      },
      child: Scaffold(
          body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Stack(
            children: [
              Column(
                children: [
                  Container(
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).viewPadding.top),
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * .15 +
                        MediaQuery.of(context).viewPadding.top,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: Text(
                            context.loc.app_title,
                            style: Theme.of(context)
                                .textTheme
                                .headlineLarge!
                                .copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                          ),
                        ),
                        Container(
                          alignment: Alignment.bottomCenter,
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height * .05,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(24),
                                topRight: Radius.circular(24)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child:
                              Lottie.asset('assets/lottie/man_kid_quran.json'),
                        ),
                        Expanded(
                          flex: 2,
                          child: Column(
                            children: [
                              Text(context.loc.login,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium),
                              Form(
                                  key: _form,
                                  child: Column(
                                    children: [
                                      TextFormField(
                                        controller: _usernameController,
                                        validator: (String? value) {
                                          if (value == null || value.isEmpty) {
                                            return context
                                                .loc.validation_enter_username;
                                          }
                                          return null;
                                        },
                                        decoration: InputDecoration(
                                          icon: const Icon(Icons.person),
                                          labelText: context.loc.username,
                                        ),
                                      ),
                                      TextFormField(
                                        controller: _passwordController,
                                        validator: (String? value) {
                                          if (value == null || value.isEmpty) {
                                            return context
                                                .loc.validation_enter_password;
                                          }
                                          return null;
                                        },
                                        decoration: InputDecoration(
                                          icon: const Icon(Icons.password),
                                          labelText: context.loc.password,
                                        ),
                                        obscureText: true,
                                      ),
                                    ],
                                  )),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * .8,
                                child: ElevatedButton(
                                    onPressed: () {
                                      FocusManager.instance.primaryFocus
                                          ?.unfocus();
                                      if (_form.currentState!.validate()) {
                                        setState(() {
                                          _loading = true;
                                        });
                                        context
                                            .read<auth.AuthCubit>()
                                            .login(_usernameController.text,
                                                _passwordController.text)
                                            .then((_) {})
                                            .catchError((e) {
                                          if (e.runtimeType ==
                                              PostgrestException) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(SnackBar(
                                                    content: Text(auth
                                                        .AuthError.wrongUsername
                                                        .translate(context))));
                                          }
                                          if (e.runtimeType ==
                                              AuthApiException) {
                                            final code = switch (
                                                (e as AuthException).code) {
                                              "email_exists" =>
                                                auth.AuthError.usernameExists,
                                              "user_not_found" =>
                                                auth.AuthError.userNotFound,
                                              "email_address_invalid" =>
                                                auth.AuthError.wrongUsername,
                                              "invalid_credentials" =>
                                                auth.AuthError.wrongPassword,
                                              _ => auth.AuthError.unknown,
                                            };
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(SnackBar(
                                                    content: Text(code
                                                        .translate(context))));
                                          }
                                          setState(() {
                                            _loading = false;
                                          });
                                        });
                                      }
                                    },
                                    child: Text(context.loc.login)),
                              ),
                              const SizedBox(
                                height: 24,
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * .8,
                                child: ElevatedButton(
                                  onPressed: () {
                                    launchUrl(Uri.parse(
                                        'mailto:mahirbilquran9@gmail.com'));
                                  },
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white),
                                  child: Text(context.loc.request_copy,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (kDebugMode)
                          TextButton(
                            onPressed: () => throw Exception(),
                            child: const Text("Throw Test Exception"),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              if (_loading) LoadingWidget()
            ],
          ),
        ),
      )),
    );
  }
}
