import 'package:al_furqan/application/auth/auth_cubit.dart';
import 'package:al_furqan/application/profile/cubit/profile_cubit.dart';
import 'package:al_furqan/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PasswordDialog extends StatefulWidget {
  const PasswordDialog({super.key});

  @override
  State<PasswordDialog> createState() => _PasswordDialogState();
}

class _PasswordDialogState extends State<PasswordDialog> {
  final GlobalKey<FormFieldState> passwordKey = GlobalKey<FormFieldState>();

  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_loading)
              const LinearProgressIndicator(
                color: Colors.white,
              ),
            TextFormField(
              key: passwordKey,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return context.loc.validation_enter_password;
                }
                return null;
              },
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: InputBorder.none,
                icon: const Icon(Icons.password),
                labelText: context.loc.password,
              ),
              obscureText: true,
            ),
            ElevatedButton(
                onPressed: () {
                  if (passwordKey.currentState!.validate()) {
                    setState(() {
                      _loading = true;
                    });
                    final userId =
                        (context.read<AuthCubit>().state as UserAuthenticated)
                            .supabaseUser
                            .id;
                    ProfileCubit.updatePassword(
                            userId, passwordKey.currentState!.value)
                        .then((_) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                              context.loc.has_been_modified_successfully)));
                      Navigator.of(context).pop();
                    }).catchError((_) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(context.loc.error_editing_user)));
                    });

                    setState(() {
                      _loading = false;
                    });
                  }
                },
                child: Text(context.loc.change_password))
          ],
        ),
      ),
    );
  }
}
