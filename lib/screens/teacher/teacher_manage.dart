import 'package:al_furqan/application/auth/auth_cubit.dart';
import 'package:al_furqan/application/services/asset_service.dart';
import 'package:al_furqan/application/teacher/teachers_cubit.dart';
import 'package:al_furqan/models/users.dart';
import 'package:al_furqan/screens/homescreen.dart';
import 'package:al_furqan/screens/teacher/register_screen.dart';
import 'package:al_furqan/screens/teacher/teacher_view.dart';
import 'package:al_furqan/utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

class TeacherManageDashboard extends StatefulWidget {
  const TeacherManageDashboard({super.key});

  @override
  State<TeacherManageDashboard> createState() => _TeacherManageDashboardState();
}

class _TeacherManageDashboardState extends State<TeacherManageDashboard> {
  final _cubit = TeachersCubit();
  late Users user;

  @override
  void initState() {
    super.initState();
    user = (context.read<AuthCubit>().state as UserAuthenticated).userData!;
    _cubit.watchTeachers(user.schoolId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.loc.teachers_list),
        automaticallyImplyLeading: true,
      ),
      body: BlocBuilder<TeachersCubit, TeachersState>(
        bloc: _cubit,
        builder: (context, state) {
          return Column(
            children: [
              if (state is TeachersLoaded)
                if (state.teachers.isEmpty)
                  Expanded(
                    child: Center(
                      child: Text(
                        context.loc.no_teachers_yet,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                  )
                else
                  Expanded(
                      child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: state.teachers.length,
                          itemBuilder: (context, index) {
                            final teacher = state.teachers[index];
                            return Card.outlined(
                              shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8))),
                              child: ListTile(
                                onTap: () {
                                  Navigator.of(context)
                                      .push(MaterialPageRoute(
                                          builder: (context) =>
                                              TeacherViewManage(
                                                teacher: teacher,
                                              )))
                                      .then((_) {
                                    _cubit.watchTeachers((context
                                            .read<AuthCubit>()
                                            .state as UserAuthenticated)
                                        .userData!
                                        .schoolId);
                                  });
                                },
                                leading: teacher.image != null &&
                                        teacher.image!.isNotEmpty
                                    ? CircleAvatar(
                                        foregroundImage:
                                            CachedNetworkImageProvider(
                                                AssetService.composeImageURL(
                                                    teacher)),
                                      )
                                    : CircleAvatar(
                                        child: Text(teacher
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
                                //                         _cubit.deleteTeacher(
                                //                             teacher);
                                //                         Navigator.of(context)
                                //                             .pop();
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
                                title: Text(teacher.fullName),
                              ),
                            );
                          }))
              else if (state is TeachersError)
                Expanded(
                  child: Center(
                    child: Text(state.message),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: 10,
                    itemBuilder: (context, index) {
                      return Shimmer.fromColors(
                          baseColor: Colors.white38,
                          highlightColor: Colors.grey[400]!,
                          child: const ListTilePlaceholder(
                            width: 250,
                          ));
                    },
                  ),
                )
            ],
          );
        },
      ),
      floatingActionButton: user.role != UserRole.admin
          ? null
          : FloatingActionButton(
              child: const Icon(Icons.add),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const RegisterScreen()));
              }),
    );
  }

  @override
  dispose() {
    _cubit.close();
    super.dispose();
  }
}
