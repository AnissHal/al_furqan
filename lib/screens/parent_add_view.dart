import 'package:al_furqan/application/auth/auth_cubit.dart';
import 'package:al_furqan/utils.dart';
import 'package:al_furqan/widgets/avatar_upload.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

class ParentAddView extends StatefulWidget {
  const ParentAddView({super.key});

  @override
  State<ParentAddView> createState() => _ParentAddViewState();
}

class _ParentAddViewState extends State<ParentAddView> {
  final GlobalKey<FormState> _form = GlobalKey<FormState>();

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();

  bool _loading = false;
  XFile? _avatar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(context.loc.add_parent),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Stack(
                children: [
                  Column(
                    children: [
                      Expanded(
                        child: Container(
                            decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(250),
                                  bottomRight: Radius.circular(250),
                                ),
                                border: Border.symmetric(
                                    vertical: BorderSide(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                        width: 24))),
                            child: AvatarUploadWidget(
                              onChange: (file) {
                                setState(() {
                                  _avatar = file;
                                });
                              },
                              loading: _loading,
                            )),
                      ),
                      Expanded(
                        flex: 3,
                        child: Column(
                          children: [
                            Text(context.loc.register,
                                style: const TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold)),
                            Form(
                                key: _form,
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                          color: Colors.grey[200], // Li
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(24))),
                                      child: TextFormField(
                                        controller: _usernameController,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return context
                                                .loc.validation_enter_username;
                                          }
                                          return null;
                                        },
                                        decoration: InputDecoration(
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  vertical: 10),
                                          border: InputBorder.none,
                                          icon: const Icon(
                                              Icons.account_box_outlined),
                                          labelText: context.loc.username,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                          color: Colors.grey[200], // Li
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(24))),
                                      child: TextFormField(
                                        controller: _passwordController,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return context
                                                .loc.validation_enter_password;
                                          }
                                          return null;
                                        },
                                        decoration: InputDecoration(
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  vertical: 10),
                                          border: InputBorder.none,
                                          icon: const Icon(Icons.password),
                                          labelText: context.loc.password,
                                        ),
                                        obscureText: true,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                          color: Colors.grey[200], // Li
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(24))),
                                      child: TextFormField(
                                        controller: _nameController,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return context
                                                .loc.validation_enter_full_name;
                                          }
                                          return null;
                                        },
                                        decoration: InputDecoration(
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  vertical: 10),
                                          border: InputBorder.none,
                                          icon: const Icon(Icons.person),
                                          labelText: context.loc.full_name,
                                        ),
                                        obscureText: true,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                          color: Colors.grey[200], // Li
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(24))),
                                      child: TextFormField(
                                        controller: _phoneController,
                                        keyboardType: TextInputType.phone,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.digitsOnly
                                        ],
                                        decoration: InputDecoration(
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  vertical: 10),
                                          border: InputBorder.none,
                                          icon: const Icon(Icons.phone),
                                          labelText: context.loc.phone,
                                        ),
                                      ),
                                    ),
                                  ],
                                )),
                            ElevatedButton(
                                onPressed: () {
                                  if (_form.currentState!.validate()) {
                                    setState(() {
                                      _loading = true;
                                    });
                                    context
                                        .read<AuthCubit>()
                                        .registerParent(
                                            (context.read<AuthCubit>().state
                                                    as UserAuthenticated)
                                                .userData!,
                                            _nameController.text,
                                            _phoneController.text,
                                            _usernameController.text,
                                            _passwordController.text,
                                            _avatar)
                                        .then((_) {
                                      if (mounted) {
                                        setState(() {
                                          _loading = false;
                                        });
                                      }
                                    }).catchError((e) {
                                      setState(() {
                                        _loading = false;
                                      });
                                    });
                                  }
                                },
                                child: Text(context.loc.register)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // if (_loading) LoadingWidget()
                ],
              ),
            ),
          ),
        ));
  }
}
