import 'dart:io';

import 'package:al_furqan/application/auth/auth_cubit.dart';
import 'package:al_furqan/application/school/cubit/school_cubit.dart';
import 'package:al_furqan/application/services/asset_service.dart';
import 'package:al_furqan/application/student/manage/student_manage_cubit.dart';
import 'package:al_furqan/models/schools.dart';
import 'package:al_furqan/utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class AvatarUserUploadWidget extends StatefulWidget {
  final StudentManageCubit? cubit;
  final void Function(XFile? image)? onChange;
  final bool? loading;
  const AvatarUserUploadWidget(
      {super.key, this.cubit, this.onChange, this.loading});

  @override
  State<AvatarUserUploadWidget> createState() => _AvatarUserUploadWidgetState();
}

class _AvatarUserUploadWidgetState extends State<AvatarUserUploadWidget> {
  bool _uploading = false;
  late StudentManageCubit? manageCubit;
  XFile? _image;

  @override
  void initState() {
    super.initState();
    manageCubit = widget.cubit;
  }

  Future<void> requestPermissions() async {
    final status = await Permission.photos.status;
    if (status == PermissionStatus.granted) return;
    await Permission.photos.request();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.loading != null) {
      _uploading = widget.loading!;
    }

    if (manageCubit == null) {
      return SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              InkWell(
                onTap: () {
                  showModalBottomSheet(
                      context: context,
                      builder: (context) => Container(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  title: Text(context.loc.add_picture),
                                  onTap: () {
                                    requestPermissions();
                                    ImagePicker()
                                        .pickImage(
                                            source: ImageSource.gallery,
                                            requestFullMetadata: true,
                                            preferredCameraDevice:
                                                CameraDevice.rear,
                                            imageQuality: 50)
                                        .then((value) {
                                      setState(() {
                                        _image = value;
                                      });
                                      if (widget.onChange != null) {
                                        widget.onChange!(value);
                                      }
                                      Navigator.pop(context);
                                    });
                                  },
                                ),
                                if (_image != null)
                                  ListTile(
                                      tileColor: Theme.of(context)
                                          .colorScheme
                                          .errorContainer,
                                      leading: const Icon(Icons.delete_forever),
                                      title: Text(context.loc.remove),
                                      onTap: () {
                                        Navigator.pop(context);

                                        setState(() {
                                          _image = null;
                                        });
                                        if (widget.onChange != null) {
                                          widget.onChange!(null);
                                        }
                                      })
                              ],
                            ),
                          ));
                },
                child: Container(
                  width: MediaQuery.of(context).size.width * .3,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Theme.of(context).colorScheme.primary)),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: _image == null
                        ? const CircleAvatar(
                            child: Icon(
                              Icons.person,
                              size: 64,
                            ),
                          )
                        : (_uploading && _image != null)
                            ? Stack(
                                fit: StackFit.expand,
                                children: [
                                  CircleAvatar(
                                    foregroundImage:
                                        Image.file(File(_image!.path)).image,
                                  ),
                                  const CircularProgressIndicator()
                                ],
                              )
                            : CircleAvatar(
                                foregroundImage:
                                    Image.file(File(_image!.path)).image,
                              ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return BlocBuilder<StudentManageCubit, StudentManageState>(
        bloc: manageCubit,
        builder: (context, state) {
          if (state is StudentManageLoaded) {
            return SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Container(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    InkWell(
                      onTap: () {
                        showModalBottomSheet(
                            context: context,
                            builder: (context) => Container(
                                  padding: const EdgeInsets.all(8),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ListTile(
                                        title: Text(context.loc.add_picture),
                                        onTap: () {
                                          requestPermissions();
                                          ImagePicker()
                                              .pickImage(
                                                  source: ImageSource.gallery,
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
                                              manageCubit!
                                                  .updateStudentImage(
                                                      value,
                                                      (context
                                                                  .read<AuthCubit>()
                                                                  .state
                                                              as UserAuthenticated)
                                                          .userData!)
                                                  .then((url) {
                                                if (url == null) return;
                                                setState(() {
                                                  _uploading = false;
                                                });
                                              }).catchError((e) {
                                                setState(() {
                                                  _uploading = false;
                                                });
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
                                              manageCubit!
                                                  .removeStudentImage()
                                                  .then((_) {
                                                setState(() {
                                                  _uploading = false;
                                                });
                                              });
                                            })
                                    ],
                                  ),
                                ));
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width * .3,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Theme.of(context).colorScheme.primary)),
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
                                              state.student.image!),
                                    ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      );
    }
  }
}

class AvatarSchoolUploadWidget extends StatefulWidget {
  final Schools? intialValue;
  final void Function(XFile? image)? onChange;
  final bool? loading;
  const AvatarSchoolUploadWidget(
      {super.key, this.onChange, this.loading, this.intialValue});

  @override
  State<AvatarSchoolUploadWidget> createState() =>
      _AvatarSchoolUploadWidgetState();
}

class _AvatarSchoolUploadWidgetState extends State<AvatarSchoolUploadWidget> {
  bool _uploading = false;

  XFile? _image;

  @override
  void initState() {
    super.initState();
  }

  Future<void> requestPermissions() async {
    final status = await Permission.photos.status;
    if (status == PermissionStatus.granted) return;
    await Permission.photos.request();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.loading != null) {
      _uploading = widget.loading!;
    }

    return BlocBuilder<SchoolCubit, SchoolState>(
      builder: (context, state) {
        if (state is SchoolLoaded) {
          return SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  InkWell(
                    onTap: () {
                      showModalBottomSheet(
                          context: context,
                          builder: (context) => Container(
                                padding: const EdgeInsets.all(8),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ListTile(
                                      title: Text(context.loc.add_picture),
                                      onTap: () {
                                        requestPermissions();
                                        ImagePicker()
                                            .pickImage(
                                                source: ImageSource.gallery,
                                                requestFullMetadata: true,
                                                preferredCameraDevice:
                                                    CameraDevice.rear,
                                                imageQuality: 50)
                                            .then((value) {
                                          if (widget.onChange != null) {
                                            widget.onChange!(value);
                                          }
                                          Navigator.pop(context);
                                        });
                                      },
                                    ),
                                    if (state.school.image != null)
                                      ListTile(
                                          tileColor: Theme.of(context)
                                              .colorScheme
                                              .errorContainer,
                                          leading:
                                              const Icon(Icons.delete_forever),
                                          title: Text(context.loc.remove),
                                          onTap: () {
                                            if (widget.onChange != null) {
                                              widget.onChange!(null);
                                            }
                                            Navigator.pop(context);
                                          })
                                  ],
                                ),
                              ));
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width * .3,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Theme.of(context).colorScheme.primary)),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: _uploading
                            ? const CircularProgressIndicator()
                            : state.school.image == null ||
                                    state.school.image!.isEmpty
                                ? const CircleAvatar(
                                    child: Icon(
                                      Icons.person,
                                      size: 64,
                                    ),
                                  )
                                : CircleAvatar(
                                    backgroundColor: Colors.white,
                                    foregroundImage: CachedNetworkImageProvider(
                                        AssetService
                                            .fetchSchoolImageFromNetwork(
                                                state.school),
                                        cacheKey: 'logo'),
                                  ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
