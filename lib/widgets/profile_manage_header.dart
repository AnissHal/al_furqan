import 'package:al_furqan/application/profile/cubit/profile_cubit.dart';
import 'package:al_furqan/application/services/asset_service.dart';
import 'package:al_furqan/models/users.dart';
import 'package:al_furqan/screens/homescreen.dart';
import 'package:al_furqan/utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shimmer/shimmer.dart';

class ProfileHeader extends StatefulWidget {
  const ProfileHeader({super.key, required this.user, required this.cubit});

  final Users user;
  final ProfileCubit cubit;

  @override
  State<ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<ProfileHeader> {
  bool _uploading = false;

  @override
  void initState() {
    widget.cubit.loadProfile(widget.user);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final manageCubit = widget.cubit;

    return RefreshIndicator(
      onRefresh: () async {
        manageCubit.loadProfile(widget.user);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            BlocBuilder<ProfileCubit, ProfileState>(
              bloc: manageCubit,
              builder: (context, state) {
                if (state is ProfileLoaded) {
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
                                                title: Text(
                                                    context.loc.add_picture),
                                                onTap: () {
                                                  ImagePicker()
                                                      .pickImage(
                                                          source: ImageSource
                                                              .gallery,
                                                          requestFullMetadata:
                                                              true,
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
                                                          .updateProfileImage(
                                                              value)
                                                          .then((url) {
                                                        if (url == null) return;
                                                        CachedNetworkImage
                                                            .evictFromCache(
                                                                url);
                                                        manageCubit.loadProfile(
                                                            widget.user);
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
                                                              .loc
                                                              .unknown_error),
                                                          actions: const [],
                                                        ));
                                                      });
                                                    }
                                                  });
                                                },
                                              ),
                                              if (state.user.image != null)
                                                ListTile(
                                                    tileColor: Theme.of(context)
                                                        .colorScheme
                                                        .errorContainer,
                                                    leading: const Icon(
                                                        Icons.delete_forever),
                                                    title: Text(
                                                        context.loc.remove),
                                                    onTap: () {
                                                      Navigator.pop(context);

                                                      setState(() {
                                                        _uploading = true;
                                                      });
                                                      manageCubit
                                                          .removeProfileImage()
                                                          .then((_) {
                                                        manageCubit.loadProfile(
                                                            widget.user);
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
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary)),
                                child: AspectRatio(
                                  aspectRatio: 1,
                                  child: _uploading
                                      ? const CircularProgressIndicator()
                                      : state.user.image == null ||
                                              state.user.image!.isEmpty
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
                                                          .composeImageURL(
                                                              state.user)),
                                            ),
                                ),
                              ),
                            ),
                            Text(
                              state.user.fullName,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 8),
                            Row(children: [
                              Expanded(
                                child: Text(context.loc.phone,
                                    style:
                                        Theme.of(context).textTheme.bodyLarge),
                              ),
                              Expanded(
                                child: Text(state.user.phone!,
                                    style:
                                        Theme.of(context).textTheme.bodyLarge),
                              ),
                            ]),
                            const SizedBox(height: 8),
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
          ],
        ),
      ),
    );
  }
}
