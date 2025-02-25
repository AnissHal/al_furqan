import 'package:al_furqan/application/services/users_service.dart';
import 'package:al_furqan/models/users.dart';
import 'package:al_furqan/utils.dart';
import 'package:flutter/material.dart';

class UserDialog extends StatefulWidget {
  const UserDialog({super.key, required this.user});
  final Users user;

  @override
  State<UserDialog> createState() => _UserDialogState();
}

class _UserDialogState extends State<UserDialog> {
  final GlobalKey<FormFieldState> userNameKey = GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> fullNameKey = GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> phoneKey = GlobalKey<FormFieldState>();
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
              LinearProgressIndicator(
                color: Theme.of(context).colorScheme.tertiary,
              ),
            TextFormField(
              initialValue: widget.user.username,
              key: userNameKey,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return context.loc.validation_enter_name;
                }
                return null;
              },
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: InputBorder.none,
                icon: const Icon(Icons.account_box),
                labelText: context.loc.username,
              ),
            ),
            const SizedBox(
              height: 12,
            ),
            TextFormField(
              key: passwordKey,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: InputBorder.none,
                icon: const Icon(Icons.password),
                labelText: context.loc.password,
              ),
              obscureText: true,
            ),
            const SizedBox(
              height: 12,
            ),
            TextFormField(
              key: fullNameKey,
              initialValue: widget.user.fullName,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return context.loc.validation_enter_full_name;
                }
                return null;
              },
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: InputBorder.none,
                icon: const Icon(Icons.person),
                labelText: context.loc.full_name,
              ),
            ),
            const SizedBox(
              height: 12,
            ),
            TextFormField(
              key: phoneKey,
              initialValue: widget.user.phone,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: InputBorder.none,
                icon: const Icon(Icons.phone),
                labelText: context.loc.phone,
              ),
            ),
            ElevatedButton(
                onPressed: () {
                  if (fullNameKey.currentState!.validate() &&
                      userNameKey.currentState!.validate()) {
                    setState(() {
                      _loading = true;
                    });

                    UsersService.modifyUserThroughEdge(
                      username: userNameKey.currentState!.value,
                      userId: widget.user.id,
                      fullName: fullNameKey.currentState!.value,
                      password:
                          (passwordKey.currentState!.value as String).isEmpty
                              ? null
                              : passwordKey.currentState!.value,
                      phone: phoneKey.currentState!.value,
                    ).then((_) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                              context.loc.has_been_modified_successfully)));
                      Navigator.of(context).pop(true);
                    }).catchError((_) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(context.loc.error_editing_user)));
                    });

                    setState(() {
                      _loading = false;
                    });
                  }
                },
                child: Text(context.loc.update_user))
          ],
        ),
      ),
    );
  }
}
