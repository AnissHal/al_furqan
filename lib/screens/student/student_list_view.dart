import 'dart:async';

import 'package:al_furqan/application/auth/auth_cubit.dart';
import 'package:al_furqan/application/student/crud/student_cubit.dart';
import 'package:al_furqan/models/student.dart';
import 'package:al_furqan/models/teacher.dart';
import 'package:al_furqan/models/users.dart';
import 'package:al_furqan/screens/homescreen.dart';
import 'package:al_furqan/screens/student/student_add_view.dart';
import 'package:al_furqan/utils.dart';
import 'package:al_furqan/widgets/student_tile.dart';
import 'package:al_furqan/widgets/student_view_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';

class StudentListScreen extends StatefulWidget {
  const StudentListScreen({super.key});

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  final int _currentPage = 0;
  bool viewAsAdmin = false;
  late Users user;

  @override
  void initState() {
    super.initState();
    user = (context.read<AuthCubit>().state as UserAuthenticated).userData!;
    if (user.role == UserRole.parent) {
      context.read<StudentCubit>().studentByParent(user.id);
    } else {
      context.read<StudentCubit>().watchStudentsByTeacher(user.id);
    }
    // context.read<ParentCubit>().watchParents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(context.loc.students_list),
      ),
      floatingActionButton:
          (user.role == UserRole.admin || user.role == UserRole.teacher)
              ? FloatingActionButton(
                  child: const Icon(Icons.add),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const StudentAddView(),
                      ),
                    );
                  },
                )
              : null,
      body: IndexedStack(index: _currentPage, children: [
        Column(children: [
          Expanded(child: BlocBuilder<StudentCubit, StudentState>(
              builder: (context, state) {
            return Column(
              children: [
                if ((context.read<AuthCubit>().state as UserAuthenticated)
                        .userData!
                        .role ==
                    UserRole.admin)
                  Row(
                    children: [
                      Checkbox(
                        value: viewAsAdmin,
                        onChanged: (value) {
                          setState(() {
                            viewAsAdmin = value!;
                          });
                          if (viewAsAdmin) {
                            context.read<StudentCubit>().watchStudentsByAdmin(
                                (context.read<AuthCubit>().state
                                        as UserAuthenticated)
                                    .userData!
                                    .schoolId);
                          } else {
                            context.read<StudentCubit>().watchStudentsByTeacher(
                                (context.read<AuthCubit>().state
                                        as UserAuthenticated)
                                    .userData!
                                    .id);
                          }
                        },
                      ),
                      Text(context.loc.show_all_students),
                    ],
                  ),
                switch (state) {
                  StudentLoaded() => Expanded(
                      child: StudentListWidget(students: state.students)),
                  StudentEmpty() => Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AspectRatio(
                            aspectRatio: 1.2,
                            child:
                                Lottie.asset('assets/lottie/girl_quran.json')),
                        Text(
                          context.loc.no_students_found,
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                      ],
                    ),
                  StudentError() => Center(child: Text(state.message)),
                  _ => Expanded(
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
                }
              ],
            );
          }))
        ]),
      ]),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class TeacherInfoBottomSheet extends StatelessWidget {
  final Teacher teacher;
  const TeacherInfoBottomSheet({super.key, required this.teacher});

  // "password" => "*asswor*"
  String hintPassword(String password) {
    final first = password.characters.first;
    final last = password.characters.last;

    return '$first${'*' * (password.length - 2)}$last';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            teacher.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          Row(
            children: [
              Text(
                context.loc.phone,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const Spacer(),
              Text(teacher.phone,
                  style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface)),
              const Spacer()
            ],
          ),
          Row(
            children: [
              Text(
                context.loc.password,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const Spacer(),
              // obscure except first and last character
              Text(hintPassword(teacher.password),
                  style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface)),
              const Spacer()
            ],
          ),
          Row(
            children: [
              Text(
                context.loc.username,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const Spacer(),
              Text(teacher.username,
                  style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface)),
              const Spacer()
            ],
          ),
        ],
      ),
    );
  }
}

class StudentListWidget extends StatefulWidget {
  const StudentListWidget({super.key, required this.students});

  final List<Student> students;

  @override
  State<StudentListWidget> createState() => _StudentListWidgetState();
}

class _StudentListWidgetState extends State<StudentListWidget> {
  final TextEditingController _controller = TextEditingController();

  final filtredStudents = <Student>[];
  late Users user;

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    user = (context.read<AuthCubit>().state as UserAuthenticated).userData!;

    _controller.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final value = _controller.text;
    if (value.isNotEmpty && mounted) {
      if (_debounce?.isActive ?? false) _debounce!.cancel();
      _debounce = Timer(const Duration(milliseconds: 300), () {
        setState(() {
          filtredStudents.clear();
          for (var element in widget.students) {
            if (element.fullName
                .toLowerCase()
                .startsWith(value.toLowerCase())) {
              filtredStudents.add(element);
            }
          }
        });
      });
    } else {
      setState(() {
        filtredStudents.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[200], // Light grey background
              borderRadius: BorderRadius.circular(30), // Rounded edges
            ),
            child: TextFormField(
              controller: _controller,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .copyWith(color: Colors.black),
              decoration: InputDecoration(
                hintStyle: const TextStyle(color: Colors.black87),
                hintText: context.loc.search_student,
                prefixIcon: const Icon(Icons.search, color: Colors.black87),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
              itemCount: _controller.text.isNotEmpty
                  ? filtredStudents.length
                  : widget.students.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                final student = _controller.text.isNotEmpty
                    ? filtredStudents[index]
                    : widget.students[index];
                return user.role == UserRole.parent
                    ? StudentViewTile(student)
                    : StudentTile(student);
              }),
        ),
      ],
    );
  }
}
