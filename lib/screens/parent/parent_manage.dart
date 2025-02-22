import 'package:al_furqan/application/auth/auth_cubit.dart';
import 'package:al_furqan/application/parent/parent_cubit.dart';
import 'package:al_furqan/application/services/asset_service.dart';
import 'package:al_furqan/models/users.dart';
import 'package:al_furqan/screens/homescreen.dart';
import 'package:al_furqan/screens/parent/parent_view.dart';
import 'package:al_furqan/screens/parent_add_view.dart';
import 'package:al_furqan/utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

class ParentManageDashboard extends StatefulWidget {
  const ParentManageDashboard({super.key});

  @override
  State<ParentManageDashboard> createState() => _ParentManageDashboardState();
}

class _ParentManageDashboardState extends State<ParentManageDashboard> {
  final _cubit = ParentCubit();
  late Users user;

  @override
  void initState() {
    super.initState();
    user = (context.read<AuthCubit>().state as UserAuthenticated).userData!;
    _cubit.watchParents(user);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.loc.parents_list),
        automaticallyImplyLeading: true,
      ),
      body: BlocBuilder<ParentCubit, ParentsState>(
        bloc: _cubit,
        builder: (context, state) {
          return Column(
            children: [
              if (state is ParentsLoaded)
                if (state.parents.isEmpty)
                  Expanded(
                    child: Center(
                      child: Text(
                        context.loc.no_parents_yet,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                  )
                else
                  Expanded(
                      child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: state.parents.length,
                          itemBuilder: (context, index) {
                            final parent = state.parents[index];
                            return Card.outlined(
                              shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8))),
                              child: ListTile(
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => ParentViewManage(
                                            parent: parent,
                                          )));
                                },
                                leading: parent.image != null &&
                                        parent.image!.isNotEmpty
                                    ? CircleAvatar(
                                        foregroundImage:
                                            CachedNetworkImageProvider(
                                                AssetService.composeImageURL(
                                                    parent)),
                                      )
                                    : CircleAvatar(
                                        child: Text(parent
                                            .fullName.characters.first
                                            .toUpperCase()),
                                      ),
                                // subtitle: Row(
                                //   mainAxisSize: MainAxisSize.min,
                                //   children: [
                                //     Expanded(
                                //         child: ElevatedButton(
                                //       onPressed: () {
                                //         showDialog(
                                //             context: context,
                                //             builder: (context) {
                                //               return AlertDialog(
                                //                 title: Text(
                                //                     context.loc.delete_ayah),
                                //                 actions: [
                                //                   TextButton(
                                //                       onPressed: () =>
                                //                           Navigator.pop(
                                //                               context),
                                //                       child: Text(
                                //                           context.loc.cancel)),
                                //                   TextButton(
                                //                       onPressed: () {
                                //                         // _cubit.deleteTeacher(
                                //                         //     parent);
                                //                         // Navigator.of(context)
                                //                         //     .pop();
                                //                       },
                                //                       child: Text(
                                //                           context.loc.remove))
                                //                 ],
                                //               );
                                //             });
                                //       },
                                //       style: ElevatedButton.styleFrom(
                                //           backgroundColor: Theme.of(context)
                                //               .colorScheme
                                //               .error,
                                //           foregroundColor: Theme.of(context)
                                //               .colorScheme
                                //               .onError),
                                //       child: Text(context.loc.remove),
                                //     )),
                                //     const SizedBox(width: 8),
                                //     Expanded(
                                //         child: ElevatedButton(
                                //       onPressed: null,
                                //       child: Text(context.loc.update_ayah),
                                //     )),
                                //     const SizedBox(width: 8),
                                //     Expanded(
                                //         child: ElevatedButton(
                                //       onPressed: null,
                                //       child: Text(context.loc.remove),
                                //     )),
                                //   ],
                                // ),
                                title: Text(parent.fullName),
                              ),
                            );
                          }))
              else if (state is ParentsError)
                Expanded(
                  child: Center(
                    child: Text(state.message),
                  ),
                )
              else
                Expanded(
                  child: ListView(children: [
                    ...List.generate(
                        8,
                        (e) => Padding(
                              padding: const EdgeInsets.all(8),
                              child: Shimmer.fromColors(
                                  baseColor: Colors.white24,
                                  highlightColor: Colors.grey,
                                  child: const ListTilePlaceholder(
                                    width: 250,
                                  )),
                            ))
                  ]),
                )
            ],
          );
        },
      ),
      floatingActionButton:
          (user.role == UserRole.admin || user.role == UserRole.teacher)
              ? FloatingActionButton(
                  child: const Icon(Icons.add),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ParentAddView(),
                      ),
                    );
                  },
                )
              : null,
    );
  }

  @override
  dispose() {
    _cubit.close();
    super.dispose();
  }
}
