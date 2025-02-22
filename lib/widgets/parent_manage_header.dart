import 'package:al_furqan/application/parent/parent_manage_cubit.dart';
import 'package:al_furqan/application/services/asset_service.dart';
import 'package:al_furqan/application/services/users_service.dart';
import 'package:al_furqan/models/users.dart';
import 'package:al_furqan/utils.dart';
import 'package:al_furqan/widgets/user_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

class ParentManageHeader extends StatefulWidget {
  const ParentManageHeader(
      {super.key, required this.cubit, required this.parent});
  final ParentManageCubit cubit;
  final Users parent;

  @override
  State<ParentManageHeader> createState() => _ParentManageHeaderState();
}

class _ParentManageHeaderState extends State<ParentManageHeader> {
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final manageCubit = widget.cubit;

    return Column(
      children: [
        BlocBuilder<ParentManageCubit, ParentManageState>(
          bloc: manageCubit,
          builder: (context, state) {
            if (state is ParentManageLoaded) {
              return SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Card.filled(
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
                                                      .updateParentImage(value)
                                                      .then((url) {
                                                    if (url == null) return;
                                                    CachedNetworkImage
                                                        .evictFromCache(url);
                                                    setState(() {
                                                      _uploading = false;
                                                    });
                                                  }).catchError((e) {
                                                    setState(() {
                                                      _uploading = false;
                                                    });
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showMaterialBanner(
                                                            MaterialBanner(
                                                      content: Text(context
                                                          .loc.unknown_error),
                                                      actions: const [],
                                                    ));
                                                  });
                                                }
                                              });
                                            },
                                          ),
                                          if (state.parent.image != null)
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
                                                      .removeParentImage()
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
                                    color:
                                        Theme.of(context).colorScheme.primary)),
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: _uploading
                                  ? const CircularProgressIndicator()
                                  : state.parent.image == null ||
                                          state.parent.image!.isEmpty
                                      ? const CircleAvatar(
                                          child: Icon(
                                            Icons.person,
                                            size: 64,
                                          ),
                                        )
                                      : CircleAvatar(
                                          foregroundImage:
                                              CachedNetworkImageProvider(
                                                  AssetService.composeImageURL(
                                                      state.parent)),
                                        ),
                            ),
                          ),
                        ),
                        Text(
                          state.parent.fullName,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        if (state.parent.phone != null) ...[
                          Row(children: [
                            Expanded(
                              child: Text(context.loc.phone,
                                  style: Theme.of(context).textTheme.bodyLarge),
                            ),
                            Expanded(
                              child: Text(state.parent.phone!,
                                  style: Theme.of(context).textTheme.bodyLarge),
                            ),
                          ])
                        ],
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            InkWell(
                              onTap: () async {
                                await showDialog(
                                  context: context,
                                  builder: (context) {
                                    return UserDialog(user: state.parent);
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
                                        Icons.edit,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                      ),
                                    ),
                                  ),
                                  Text(context.loc.edit_user)
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
                                              title:
                                                  Text(context.loc.delete_ayah),
                                              actions: [
                                                TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(context),
                                                    child: Text(
                                                        context.loc.cancel)),
                                                TextButton(
                                                    onPressed: () {
                                                      UsersService.deleteParent(
                                                              state.parent)
                                                          .then((v) {
                                                        Navigator.of(context)
                                                            .pop(v);
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
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ],
    );
  }
}
