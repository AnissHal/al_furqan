import 'package:al_furqan/application/parent/parent_manage_cubit.dart';
import 'package:al_furqan/application/student/crud/student_cubit.dart';
import 'package:al_furqan/models/users.dart';
import 'package:al_furqan/screens/homescreen.dart';
import 'package:al_furqan/utils.dart';
import 'package:al_furqan/widgets/parent_manage_header.dart';
import 'package:al_furqan/widgets/student_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

class ParentViewManage extends StatefulWidget {
  const ParentViewManage({super.key, required this.parent});
  final Users parent;

  @override
  State<ParentViewManage> createState() => _ParentViewManageState();
}

class _ParentViewManageState extends State<ParentViewManage> {
  final _cubit = ParentManageCubit();
  final _studentCubit = StudentCubit();

  @override
  void initState() {
    super.initState();
    _cubit.loadParent(widget.parent);
    _studentCubit.studentByParent(widget.parent.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: BlocBuilder<ParentManageCubit, ParentManageState>(
        bloc: _cubit,
        builder: (context, state) {
          if (state is ParentManageLoaded) {
            return Column(children: [
              ParentManageHeader(cubit: _cubit, parent: state.parent),
              BlocBuilder<StudentCubit, StudentState>(
                bloc: _studentCubit,
                builder: (context, state) {
                  if (state is StudentLoaded) {
                    if (state.students.isEmpty) {
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
                            itemCount: state.students.length,
                            itemBuilder: (context, index) {
                              final student = state.students[index];
                              return StudentTile(student);
                            }));
                  }
                  if (state is StudentEmpty) {
                    return Center(
                      child: Text(context.loc.no_students_found),
                    );
                  }
                  if (state is StudentError) {
                    return Center(
                      child: Text(context.loc.unknown_error),
                    );
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
                },
              )
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
    _studentCubit.close();
    super.dispose();
  }
}
