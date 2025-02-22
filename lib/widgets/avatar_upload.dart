import 'dart:io';

import 'package:al_furqan/application/services/asset_service.dart';
import 'package:al_furqan/application/student/manage/student_manage_cubit.dart';
import 'package:al_furqan/utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class AvatarUploadWidget extends StatefulWidget {
  final StudentManageCubit? cubit;
  final void Function(XFile? image)? onChange;
  final bool? loading;
  const AvatarUploadWidget(
      {super.key, this.cubit, this.onChange, this.loading});

  @override
  State<AvatarUploadWidget> createState() => _AvatarUploadWidgetState();
}

class _AvatarUploadWidgetState extends State<AvatarUploadWidget> {
  bool _uploading = false;
  late StudentManageCubit? manageCubit;
  XFile? _image;
  String? _uriImage;

  @override
  void initState() {
    super.initState();
    manageCubit = widget.cubit;
    if (manageCubit != null) {
      final s = manageCubit!.state as StudentManageLoaded;
      _uriImage = s.student.image;
    }
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
                                                _image = value;
                                              });
                                              if (widget.onChange != null) {
                                                widget.onChange!(_image);
                                              }
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
                                                _image = null;
                                                _uriImage = null;
                                              });
                                              if (widget.onChange != null) {
                                                widget.onChange!(_image);
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
                              ? _uriImage != null
                                  ? CircleAvatar(
                                      foregroundImage:
                                          CachedNetworkImageProvider(
                                              AssetService
                                                  .composeStudentImageURL(
                                                      state.student)))
                                  : const CircleAvatar(
                                      child: Icon(
                                        Icons.person,
                                        size: 64,
                                      ),
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
            return const Center(child: CircularProgressIndicator());
          }
        },
      );
    }
  }
}
