import 'package:al_furqan/application/auth/auth_cubit.dart';
import 'package:al_furqan/application/school/cubit/school_cubit.dart';
import 'package:al_furqan/application/services/asset_service.dart';
import 'package:al_furqan/application/services/parent_service.dart';
import 'package:al_furqan/application/services/school_service.dart';
import 'package:al_furqan/application/services/student_service.dart';
import 'package:al_furqan/application/services/users_service.dart';
import 'package:al_furqan/models/schools.dart';
import 'package:al_furqan/models/users.dart';
import 'package:al_furqan/screens/homescreen.dart';
import 'package:al_furqan/utils.dart';
import 'package:al_furqan/widgets/avatar_user_upload.dart';
import 'package:al_furqan/widgets/school_map.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

class SchoolScreen extends StatefulWidget {
  const SchoolScreen({super.key});

  @override
  State<SchoolScreen> createState() => _SchoolScreenState();
}

class _SchoolScreenState extends State<SchoolScreen> {
  late Users user;
  late Future<Users> _adminFuture;
  late Future<int>? _teacherCount;
  late Future<int>? _parentCount;
  late Future<int>? _studentCount;

  @override
  void initState() {
    super.initState();
    user = (context.read<AuthCubit>().state as UserAuthenticated).userData!;
    final schoolId =
        (context.read<SchoolCubit>().state as SchoolLoaded).school.id;

    _adminFuture = SchoolService.fetchSchoolAdmin(schoolId);
    if (user.role == UserRole.parent) {
      _teacherCount = UsersService.countUsersBySchool(schoolId);
      _studentCount = StudentService.countStudentsBySchool(schoolId);
      _parentCount = ParentService.countParentsBySchool(schoolId);
    } else {
      _teacherCount = null;
      _studentCount = null;
      _parentCount = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
              (context.watch<SchoolCubit>().state as SchoolLoaded).school.name),
        ),
        body: BlocBuilder<SchoolCubit, SchoolState>(
          builder: (context, state) {
            if (state is SchoolLoaded) {
              return Column(children: [
                Expanded(
                  child: Container(
                    color: Theme.of(context).colorScheme.primary,
                    child: Stack(children: [
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          height: 100,
                          decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(24),
                                  topRight: Radius.circular(24))),
                        ),
                      ),
                      Center(
                          child: AvatarSchoolUploadWidget(
                        intialValue: state.school,
                        onChange: (image) {
                          if (image == null) {
                            context.read<SchoolCubit>().deleteSchoolImage();
                            return;
                          }
                          context.read<SchoolCubit>().updateSchoolImage(image);
                        },
                      ))
                    ]),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          state.school.name,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ),
                      const SizedBox(
                        height: 24,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            context.loc.address,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall!
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            state.school.address,
                            style: Theme.of(context).textTheme.headlineSmall,
                          )
                        ],
                      ),
                      FutureBuilder(
                          future: _adminFuture,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              if (snapshot.data == null) {
                                return const SizedBox.shrink();
                              }
                              return Container(
                                  margin: const EdgeInsets.all(8),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey,
                                      ),
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(24))),
                                  child: Row(children: [
                                    Expanded(
                                      child: Text(
                                          context.loc.school_administrator,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge),
                                    ),
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Text(snapshot.data!.fullName,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge),
                                          const SizedBox(
                                            width: 8,
                                          ),
                                          CircleAvatar(
                                            foregroundImage: snapshot
                                                            .data!.image !=
                                                        null &&
                                                    snapshot
                                                        .data!.image!.isNotEmpty
                                                ? CachedNetworkImageProvider(
                                                    AssetService
                                                        .composeImageURL(
                                                            snapshot.data!))
                                                : null,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ]));
                            }
                            if (snapshot.hasError) {
                              return const SizedBox.shrink();
                            }
                            return Shimmer.fromColors(
                              baseColor: Colors.grey[200]!,
                              highlightColor: Colors.grey,
                              child: TitlePlaceholder(
                                width: MediaQuery.of(context).size.width * .9,
                                height: 48,
                              ),
                            );
                          }),
                      const SizedBox(
                        height: 12,
                      ),
                      const Divider(
                        endIndent: 50,
                        indent: 50,
                        thickness: 2,
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      if (user.role != UserRole.parent) ...[
                        Center(
                          child: Text(
                            "Statistics",
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                        ),
                        const SizedBox(
                          height: 24,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  Text(
                                    context.loc.parents,
                                    style:
                                        Theme.of(context).textTheme.bodyLarge,
                                  ),
                                  Container(
                                    width: 100,
                                    height: 100,
                                    decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.red),
                                    child: Center(
                                        child: FutureBuilder<int>(
                                            future: _parentCount,
                                            builder: (context, snapshot) {
                                              if (snapshot.hasData) {
                                                return Text(
                                                  snapshot.data!.toString(),
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .headlineSmall,
                                                );
                                              }
                                              return const CircularProgressIndicator();
                                            })),
                                  )
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  Text(
                                    context.loc.teachers,
                                    style:
                                        Theme.of(context).textTheme.bodyLarge,
                                  ),
                                  Container(
                                    width: 100,
                                    height: 100,
                                    decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.green),
                                    child: Center(
                                        child: FutureBuilder<int>(
                                            future: _teacherCount,
                                            builder: (context, snapshot) {
                                              if (snapshot.hasData) {
                                                return Text(
                                                  snapshot.data!.toString(),
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .headlineSmall,
                                                );
                                              }
                                              return const CircularProgressIndicator();
                                            })),
                                  )
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  Text(
                                    context.loc.students,
                                    style:
                                        Theme.of(context).textTheme.bodyLarge,
                                  ),
                                  Container(
                                    width: 100,
                                    height: 100,
                                    decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.teal),
                                    child: Center(
                                        child: FutureBuilder<int>(
                                            future: _studentCount,
                                            builder: (context, snapshot) {
                                              if (snapshot.hasData) {
                                                return Text(
                                                  snapshot.data!.toString(),
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .headlineSmall,
                                                );
                                              }
                                              return const CircularProgressIndicator();
                                            })),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        const Divider(
                          endIndent: 50,
                          indent: 50,
                          thickness: 2,
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        if (user.role == UserRole.admin)
                          ListTile(
                            onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (context) => EditDialog(
                                        school: state.school,
                                      ));
                            },
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24)),
                            tileColor:
                                Theme.of(context).colorScheme.tertiaryContainer,
                            leading: const Icon(Icons.edit),
                            title: Text(context.loc.edit,
                                style: Theme.of(context).textTheme.bodyLarge),
                          ),
                      ] else ...[
                        if (state.school.lat != null &&
                            state.school.long != null) ...[
                          Center(
                            child: Text(context.loc.location,
                                style: Theme.of(context).textTheme.bodyLarge),
                          ),
                          Expanded(child: SchoolMap(school: state.school)),
                        ],
                        ListTile(
                          onTap: () {
                            _adminFuture.then((admin) {
                              launchUrl(Uri.parse("tel:${admin.phone!}"),
                                  mode: LaunchMode.externalApplication);
                            });
                          },
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24)),
                          tileColor:
                              Theme.of(context).colorScheme.tertiaryContainer,
                          leading: const Icon(Icons.phone),
                          title: Text(context.loc.contact_admin,
                              style: Theme.of(context).textTheme.bodyLarge),
                        ),
                      ]
                    ],
                  ),
                )
              ]);
            }
            return HeaderPlaceholder(width: MediaQuery.of(context).size.width);
          },
        ));
  }
}

class EditDialog extends StatefulWidget {
  const EditDialog({super.key, required this.school});
  final Schools school;

  @override
  State<EditDialog> createState() => _EditDialogState();
}

class _EditDialogState extends State<EditDialog> {
  final GlobalKey<FormFieldState> nameKey = GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> addressKey = GlobalKey<FormFieldState>();

  bool _loading = false;

  @override
  void initState() {
    super.initState();
  }

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
              key: nameKey,
              initialValue: widget.school.name,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return context.loc.validation_enter_password;
                }
                return null;
              },
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: InputBorder.none,
                icon: const Icon(Icons.school),
                labelText: context.loc.school,
              ),
            ),
            const SizedBox(
              height: 12,
            ),
            TextFormField(
              key: addressKey,
              initialValue: widget.school.address,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return context.loc.validation_enter_password;
                }
                return null;
              },
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: InputBorder.none,
                icon: const Icon(Icons.location_city),
                labelText: context.loc.address,
              ),
            ),
            const SizedBox(
              height: 12,
            ),
            ElevatedButton(
                onPressed: () {
                  if (nameKey.currentState!.validate()) {
                    setState(() {
                      _loading = true;
                    });
                    final user =
                        (context.read<AuthCubit>().state as UserAuthenticated)
                            .userData;
                    if (user!.role != UserRole.admin) return;

                    context
                        .read<SchoolCubit>()
                        .updateSchool(
                            address: addressKey.currentState!.value,
                            name: nameKey.currentState!.value)
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
                child: Text(context.loc.edit))
          ],
        ),
      ),
    );
  }
}
