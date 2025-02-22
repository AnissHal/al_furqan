import 'dart:convert';

import 'package:al_furqan/application/auth/auth_cubit.dart';
import 'package:al_furqan/application/services/asset_service.dart';
import 'package:al_furqan/application/services/parent_service.dart';
import 'package:al_furqan/application/services/student_service.dart';
import 'package:al_furqan/application/services/teacher_service.dart';
import 'package:al_furqan/application/student/crud/student_cubit.dart';
import 'package:al_furqan/application/student/manage/student_manage_cubit.dart';
import 'package:al_furqan/models/student.dart';
import 'package:al_furqan/models/users.dart';
import 'package:al_furqan/screens/badge_screen.dart';
import 'package:al_furqan/screens/homescreen.dart';
import 'package:al_furqan/screens/parent/parent_view.dart';
import 'package:al_furqan/screens/teacher/teacher_view.dart';
import 'package:al_furqan/utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shimmer/shimmer.dart';

class StudentManageHeader extends StatefulWidget {
  const StudentManageHeader(
      {super.key, required this.cubit, required this.student});
  final StudentManageCubit cubit;
  final Student student;

  @override
  State<StudentManageHeader> createState() => _StudentManageHeaderState();
}

class _StudentManageHeaderState extends State<StudentManageHeader> {
  late Future<Users> _futureParent;
  late Future<Users> _futureTeacher;

  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    _futureParent = ParentService.getParentByStudent(widget.student.id);
    _futureTeacher =
        TeacherService.getTeacherByStudent(widget.student.teacherId);
  }

  @override
  Widget build(BuildContext context) {
    final manageCubit = widget.cubit;

    return Column(
      children: [
        BlocBuilder<StudentManageCubit, StudentManageState>(
          bloc: manageCubit,
          builder: (context, state) {
            if (state is StudentManageLoaded) {
              return SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Card.filled(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      children: [
                        InkWell(
                          onTap: () {
                            showModalBottomSheet<bool?>(
                                context: context,
                                builder: (context) => Container(
                                      padding: const EdgeInsets.all(8),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          ListTile(
                                            title:
                                                Text(context.loc.add_picture),
                                            onTap: () {
                                              ImagePicker()
                                                  .pickImage(
                                                      source:
                                                          ImageSource.gallery,
                                                      requestFullMetadata: true,
                                                      preferredCameraDevice:
                                                          CameraDevice.rear,
                                                      imageQuality: 50)
                                                  .then((value) {
                                                if (value != null) {
                                                  Navigator.pop(context);

                                                  setState(() {
                                                    _uploading = true;
                                                  });
                                                  manageCubit
                                                      .updateStudentImage(
                                                          value,
                                                          (context
                                                                      .read<
                                                                          AuthCubit>()
                                                                      .state
                                                                  as UserAuthenticated)
                                                              .userData!)
                                                      .then((url) {
                                                    setState(() {
                                                      _uploading = false;
                                                    });
                                                    return false;
                                                  }).catchError((e) {
                                                    setState(() {
                                                      _uploading = false;
                                                    });
                                                    return false;
                                                  });
                                                }
                                              });
                                            },
                                          ),
                                          if (state.student.image != null)
                                            ListTile(
                                                tileColor: Theme.of(context)
                                                    .colorScheme
                                                    .errorContainer,
                                                leading: const Icon(
                                                    Icons.delete_forever),
                                                title: Text(context.loc.remove),
                                                onTap: () {
                                                  Navigator.pop(context);

                                                  setState(() {
                                                    _uploading = true;
                                                  });
                                                  manageCubit
                                                      .removeStudentImage()
                                                      .then((_) {
                                                    setState(() {
                                                      _uploading = false;
                                                    });
                                                  });
                                                })
                                        ],
                                      ),
                                    )).then((v) {
                              if (v == false) {
                                ScaffoldMessenger.of(context)
                                    .showMaterialBanner(MaterialBanner(
                                  content: Text(context.loc.unknown_error),
                                  actions: const [],
                                ));
                              }
                            });
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width * .3,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color:
                                        Theme.of(context).colorScheme.primary)),
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: _uploading
                                  ? const CircularProgressIndicator()
                                  : state.student.image == null ||
                                          state.student.image!.isEmpty
                                      ? const CircleAvatar(
                                          child: Icon(
                                            Icons.person,
                                            size: 64,
                                          ),
                                        )
                                      : CircleAvatar(
                                          foregroundImage:
                                              CachedNetworkImageProvider(
                                                  AssetService
                                                      .composeStudentImageURL(
                                                          state.student)),
                                        ),
                            ),
                          ),
                        ),
                        Text(
                          state.student.fullName,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Row(children: [
                          Expanded(
                            child: Text(context.loc.age,
                                style: Theme.of(context).textTheme.bodyLarge),
                          ),
                          Expanded(
                            child: Text(state.student.age.toString(),
                                style: Theme.of(context).textTheme.bodyLarge),
                          ),
                        ]),
                        const SizedBox(height: 8),
                        Row(children: [
                          Expanded(
                            child: Text(context.loc.phone,
                                style: Theme.of(context).textTheme.bodyLarge),
                          ),
                          Expanded(
                            child: Text(state.student.phone,
                                style: Theme.of(context).textTheme.bodyLarge),
                          ),
                        ]),
                        const SizedBox(height: 8),
                        FutureBuilder(
                            future: _futureParent,
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                if (snapshot.data == null) {
                                  return const SizedBox.shrink();
                                }
                                return InkWell(
                                  onTap: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ParentViewManage(
                                                    parent: snapshot.data!)));
                                  },
                                  child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.grey,
                                          ),
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(24))),
                                      child: Row(children: [
                                        Expanded(
                                          child: Text(context.loc.parent,
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
                                                foregroundImage:
                                                    CachedNetworkImageProvider(
                                                        AssetService
                                                            .composeImageURL(
                                                                snapshot
                                                                    .data!)),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ])),
                                );
                              }
                              if (snapshot.hasError) {
                                return const SizedBox.shrink();
                              }
                              return const SizedBox.shrink();
                            }),
                        const SizedBox(height: 8),
                        FutureBuilder(
                            future: _futureTeacher,
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                if (snapshot.data == null) {
                                  return const SizedBox.shrink();
                                }
                                return InkWell(
                                  onLongPress: () {
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return DialogTeacherSet(
                                            selected: snapshot.data!,
                                            onChange: (teacher) async {
                                              await TeacherService
                                                  .changeStudentTeacher(
                                                      state.student, teacher);
                                              setState(() {
                                                _futureTeacher = TeacherService
                                                    .getTeacherByStudent(
                                                        teacher.id);
                                              });
                                            },
                                          );
                                        });
                                  },
                                  onTap: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                TeacherViewManage(
                                                    teacher: snapshot.data!)));
                                  },
                                  child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.grey,
                                          ),
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(24))),
                                      child: Row(children: [
                                        Expanded(
                                          child: Text(context.loc.teachers,
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
                                                        snapshot.data!.image!
                                                            .isNotEmpty
                                                    ? CachedNetworkImageProvider(
                                                        AssetService
                                                            .composeImageURL(
                                                                snapshot.data!))
                                                    : null,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ])),
                                );
                              }
                              if (snapshot.hasError) {
                                return const SizedBox.shrink();
                              }
                              return const SizedBox.shrink();
                            }),
                        const SizedBox(
                          height: 8,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            InkWell(
                              onTap: () async {
                                await showDialog(
                                  context: context,
                                  builder: (context) {
                                    return Dialog(
                                      backgroundColor: Colors.white,
                                      child: AspectRatio(
                                        aspectRatio: 1,
                                        child: Center(
                                          child: QrImageView(
                                            data: jsonEncode(
                                                {'id': state.student.id}),
                                            size: 256,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                              child: Column(
                                children: [
                                  CircleAvatar(
                                    backgroundColor:
                                        Theme.of(context).colorScheme.primary,
                                    child: IconButton(
                                      onPressed: null,
                                      icon: Icon(
                                        Icons.qr_code,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                      ),
                                    ),
                                  ),
                                  const Text("QR")
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                InkWell(
                                  onTap: () {
                                    showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                              title: Text(
                                                  context.loc.delete_student),
                                              actions: [
                                                TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(context),
                                                    child: Text(
                                                        context.loc.cancel)),
                                                TextButton(
                                                    onPressed: () {
                                                      StudentService
                                                              .removeStudent(
                                                                  widget.student
                                                                      .id)
                                                          .then((v) {
                                                        Navigator.of(context)
                                                            .pop(v);
                                                        context
                                                            .read<
                                                                StudentCubit>()
                                                            .watchStudentsByAdmin((context
                                                                        .read<
                                                                            AuthCubit>()
                                                                        .state
                                                                    as UserAuthenticated)
                                                                .userData!
                                                                .schoolId);
                                                      });
                                                    },
                                                    child: Text(
                                                        context.loc.remove)),
                                              ],
                                            )).then((v) {
                                      if (v == true) {
                                        Navigator.of(context).pop();
                                      }
                                    });
                                  },
                                  child: CircleAvatar(
                                    backgroundColor: Theme.of(context)
                                        .colorScheme
                                        .errorContainer,
                                    child: IconButton(
                                      onPressed: null,
                                      icon: Icon(
                                        Icons.delete,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onErrorContainer,
                                      ),
                                    ),
                                  ),
                                ),
                                Text(context.loc.remove)
                              ],
                            ),
                            Column(
                              children: [
                                InkWell(
                                  onTap: () {},
                                  child: CircleAvatar(
                                    backgroundColor:
                                        Theme.of(context).colorScheme.primary,
                                    child: IconButton(
                                      onPressed: () {
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder:
                                                    (context) => BadgeScreen(
                                                          avatar: widget.student
                                                                      .image ==
                                                                  null
                                                              ? null
                                                              : AssetService.getAvatarPublicUrl(
                                                                  widget.student
                                                                      .image!,
                                                                  widget.student
                                                                      .schoolId),
                                                          student:
                                                              widget.student,
                                                        )));
                                      },
                                      icon: Icon(
                                        Icons.badge,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                      ),
                                    ),
                                  ),
                                ),
                                Text(context.loc.badge)
                              ],
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              );
            }
            return Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: HeaderPlaceholder(
                  width: MediaQuery.of(context).size.width,
                ));
          },
        ),
        Card.filled(
          child: Row(
            children: [
              Expanded(
                  child: BlocBuilder<StudentManageCubit, StudentManageState>(
                bloc: manageCubit,
                builder: (context, state) {
                  if (state is StudentManageLoaded) {
                    return ElevatedButton(
                      onPressed: () {
                        manageCubit.toggleStudentRequest();
                      },
                      style: state.student.requested == true
                          ? ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber)
                          : null,
                      child: state.student.requested == true
                          ? Text(context.loc.stop_request)
                          : Text(context.loc.request_parent),
                    );
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ))
            ],
          ),
        ),
      ],
    );
  }
}

class DialogTeacherSet extends StatefulWidget {
  const DialogTeacherSet(
      {super.key, required this.selected, required this.onChange});
  final Users selected;
  final Function(Users) onChange;

  @override
  State<DialogTeacherSet> createState() => _DialogTeacherSetState();
}

class _DialogTeacherSetState extends State<DialogTeacherSet> {
  List<Users> teachers = [];
  late Users _selectedTeacher;
  late Function _onChange;
  @override
  void initState() {
    _selectedTeacher = widget.selected;
    _onChange = widget.onChange;
    final teacher =
        (context.read<AuthCubit>().state as UserAuthenticated).userData;
    TeacherService.getTeachersList(teacher!.schoolId).then((t) {
      setState(() {
        teachers = t;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      children: [
        DropdownSearch<Users>(
          validator: (value) {
            if (value == null) {
              return context.loc.validation_select_parent;
            }
            return null;
          },
          selectedItem: _selectedTeacher,
          items: teachers,
          itemAsString: (teacher) => teacher.fullName,
          clearButtonProps: const ClearButtonProps(
            isVisible: false,
          ),
          dropdownDecoratorProps: DropDownDecoratorProps(
            dropdownSearchDecoration: InputDecoration(
              labelText: context.loc.teachers,
              hintText: context.loc.form_select_search_parent,
            ),
          ),
          dropdownBuilder: (context, selectedItem) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.person_3),
                if (selectedItem != null)
                  Expanded(
                    child: ListTile(
                      leading: selectedItem.image != null &&
                              selectedItem.image!.isNotEmpty
                          ? CircleAvatar(
                              foregroundImage: CachedNetworkImageProvider(
                                  AssetService.composeImageURL(selectedItem)),
                            )
                          : CircleAvatar(
                              child: Text(selectedItem.fullName.characters.first
                                  .toUpperCase()),
                            ),
                      title: Text(selectedItem.fullName),
                    ),
                  )
                else
                  Text(context.loc.form_select_parent),
              ],
            );
          },
          onChanged: (value) {
            if (value == null) return;
            _onChange(value);
            setState(() {
              _selectedTeacher = value;
            });
          },
          popupProps: PopupProps.menu(
            itemBuilder: (context, item, isSelected) => ListTile(
              leading: item.image != null && item.image!.isNotEmpty
                  ? CircleAvatar(
                      foregroundImage: CachedNetworkImageProvider(
                          AssetService.composeImageURL(item)),
                    )
                  : CircleAvatar(
                      child: Text(item.fullName.characters.first.toUpperCase()),
                    ),
              title: Text(item.fullName),
            ),

            showSearchBox: true, // Enables autocomplete
            searchFieldProps: TextFieldProps(
              decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.person_3),
                  hintText: context.loc.form_select_search_parent),
            ),
          ),
        )
      ],
    );
  }
}
