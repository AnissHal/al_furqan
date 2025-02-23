import 'package:al_furqan/application/auth/auth_cubit.dart';
import 'package:al_furqan/application/services/student_service.dart';
import 'package:al_furqan/application/teacher/teacher_manage_cubit.dart';
import 'package:al_furqan/models/users.dart';
import 'package:al_furqan/screens/homescreen.dart';
import 'package:al_furqan/utils.dart';
import 'package:al_furqan/widgets/student_tile.dart';
import 'package:al_furqan/widgets/teacher_manage_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

class TeacherViewManage extends StatefulWidget {
  const TeacherViewManage({super.key, required this.teacher});
  final Users teacher;

  @override
  State<TeacherViewManage> createState() => _TeacherViewManageState();
}

class _TeacherViewManageState extends State<TeacherViewManage> {
  final _cubit = TeacherManageCubit();
  late Future getStudents;
  late Users user;

  @override
  void initState() {
    super.initState();
    _cubit.loadTeacher(widget.teacher);
    user = (context.read<AuthCubit>().state as UserAuthenticated).userData!;
    getStudents = StudentService.getStudentsByTeacher(
      widget.teacher.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: BlocBuilder<TeacherManageCubit, TeacherManageState>(
        bloc: _cubit,
        builder: (context, state) {
          if (state is TeacherManageLoaded) {
            return Column(children: [
              TeacherManageHeader(cubit: _cubit, teacher: state.teacher),
              if (user.role == UserRole.parent)
                Expanded(
                  child: ListView(
                    children: [
                      ListTile(
                        onTap: () {
                          launchUrl(Uri.parse("tel:${state.teacher.phone!}"),
                              mode: LaunchMode.externalApplication);
                        },
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24)),
                        tileColor:
                            Theme.of(context).colorScheme.tertiaryContainer,
                        leading: const Icon(Icons.phone),
                        title: Text(context.loc.contact_teacher,
                            style: Theme.of(context).textTheme.bodyLarge),
                      ),
                    ],
                  ),
                )
              else
                FutureBuilder(
                    future: getStudents,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        if (snapshot.data.isEmpty) {
                          return Expanded(
                            child: Center(
                                child: Text(
                              context.loc.no_students_found,
                              style: Theme.of(context).textTheme.bodyLarge,
                            )),
                          );
                        }
                        return Expanded(
                            child: ListView.builder(
                                itemCount: snapshot.data.length,
                                itemBuilder: (context, index) {
                                  final student = snapshot.data[index];
                                  return StudentTile(student);
                                }));
                      }
                      return Expanded(
                        child: ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: 5,
                          itemBuilder: (context, index) {
                            return Shimmer.fromColors(
                                baseColor: Colors.white38,
                                highlightColor: Colors.grey[400]!,
                                child: const ListTilePlaceholder(
                                  width: 250,
                                ));
                          },
                        ),
                      );
                    })
            ]);
          }
          return Column(
            children: [
              Expanded(
                  child: Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
                      child: HeaderPlaceholder(
                          width: MediaQuery.of(context).size.width))),
              Expanded(
                child: ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 5,
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
    );
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }
}
