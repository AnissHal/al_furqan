import 'dart:async';

import 'package:al_furqan/application/auth/auth_cubit.dart';
import 'package:al_furqan/application/student/attendance/attendance_cubit.dart';
import 'package:al_furqan/application/student/crud/student_cubit.dart';
import 'package:al_furqan/models/student.dart';
import 'package:al_furqan/models/users.dart';
import 'package:al_furqan/screens/homescreen.dart';
import 'package:al_furqan/screens/scanner_screen.dart';
import 'package:al_furqan/utils.dart';
import 'package:al_furqan/widgets/student_attendance_tile.dart';
import 'package:date_field/date_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';

class PresenceScreen extends StatefulWidget {
  const PresenceScreen({super.key});

  @override
  State<PresenceScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<PresenceScreen> {
  final int _currentPage = 0;
  bool viewAsAdmin = false;
  final _cubit = StudentCubit();
  late Users _user;

  @override
  void initState() {
    super.initState();
    final stateUser =
        (context.read<AuthCubit>().state as UserAuthenticated).userData!;
    _user = stateUser;
    if (stateUser.role == UserRole.parent) {
      _cubit.studentByParent(stateUser.id);
    } else {
      _cubit.getStudentsByTeacher((stateUser.id));
    }
    // context.read<ParentCubit>().watchParents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(context.loc.attendance_screen),
      ),
      floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.camera_alt),
          onPressed: () {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const ScannerScreen()));
          }),
      body: IndexedStack(index: _currentPage, children: [
        Column(children: [
          Expanded(
              child: BlocBuilder<StudentCubit, StudentState>(
                  bloc: _cubit,
                  builder: (context, state) {
                    return Column(
                      children: [
                        if (_user.role == UserRole.admin)
                          Row(
                            children: [
                              Checkbox(
                                value: viewAsAdmin,
                                onChanged: (value) {
                                  setState(() {
                                    viewAsAdmin = value!;
                                  });
                                  if (viewAsAdmin) {
                                    _cubit.watchStudentsByAdmin((context
                                            .read<AuthCubit>()
                                            .state as UserAuthenticated)
                                        .userData!
                                        .schoolId);
                                  } else {
                                    _cubit.getStudentsByTeacher((context
                                            .read<AuthCubit>()
                                            .state as UserAuthenticated)
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
                              child:
                                  StudentListWidget(students: state.students)),
                          StudentEmpty() => Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AspectRatio(
                                    aspectRatio: 1.2,
                                    child: Lottie.asset(
                                        'assets/lottie/girl_quran.json')),
                                Text(
                                  context.loc.no_students_found,
                                  style:
                                      Theme.of(context).textTheme.headlineLarge,
                                ),
                              ],
                            ),
                          StudentError() => RefreshIndicator(
                              onRefresh: () async {
                                if (_user.role == UserRole.parent) {
                                  _cubit.studentByParent(_user.id);
                                } else {
                                  _cubit.getStudentsByTeacher((_user.id));
                                }
                              },
                              child: SizedBox(
                                height: MediaQuery.of(context).size.height * .8,
                                child: SingleChildScrollView(
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Center(child: Text(state.message)),
                                      ],
                                    )),
                              )),
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

class StudentListWidget extends StatefulWidget {
  const StudentListWidget({super.key, required this.students});

  final List<Student> students;

  @override
  State<StudentListWidget> createState() => _StudentListWidgetState();
}

class _StudentListWidgetState extends State<StudentListWidget> {
  final TextEditingController _controller = TextEditingController();

  final filtredStudents = <Student>[];
  DateTime _selectedDate = DateTime.now();
  late Users _user;
  final _attendanceCubit = AttendanceCubit();
  bool _loading = true;

  Timer? _debounce;
  Timer? _fetchDebounce;

  @override
  void initState() {
    super.initState();
    final stateUser =
        (context.read<AuthCubit>().state as UserAuthenticated).userData!;
    _user = stateUser;
    _attendanceCubit.fetchAttendanceByDate(_selectedDate);
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

  void _onDateChange(DateTime d) {
    setState(() {
      _selectedDate = d;
      _loading = true;
    });
    if (_fetchDebounce?.isActive ?? false) _fetchDebounce!.cancel();
    _fetchDebounce = Timer(const Duration(milliseconds: 300), () {
      _attendanceCubit.fetchAttendanceByDate(d);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AttendanceCubit, AttendanceState>(
      bloc: _attendanceCubit,
      listener: (context, state) {
        if (state is AttendanceLoaded) {
          WidgetsBinding.instance.addPostFrameCallback((timestamp) {
            setState(() {
              _loading = false;
            });
          });
        }
      },
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                  onPressed: () {
                    _onDateChange(_selectedDate.add(const Duration(days: 1)));
                  },
                  icon: const Icon(Icons.arrow_back)),
              Expanded(
                child: DateTimeFormField(
                  initialValue: _selectedDate,
                  mode: DateTimeFieldPickerMode.date,
                  dateFormat: DateFormat('EEEE dd MMMM yyyy', 'ar-DZ'),
                  canClear: false,
                  onChanged: (d) {
                    if (d == null) return;
                    _onDateChange(d);
                  },
                  decoration: InputDecoration(
                    hintStyle: const TextStyle(color: Colors.black87),
                    hintText: context.loc.date,
                    prefixIcon:
                        const Icon(Icons.date_range, color: Colors.black87),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2026),
                ),
              ),
              IconButton(
                  onPressed: () {
                    _onDateChange(
                        _selectedDate.subtract(const Duration(days: 1)));
                  },
                  icon: const Icon(Icons.arrow_forward)),
            ],
          ),
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
            child: RefreshIndicator(
              onRefresh: () async =>
                  _attendanceCubit.fetchAttendanceByDate(_selectedDate),
              child: BlocBuilder<AttendanceCubit, AttendanceState>(
                  bloc: _attendanceCubit,
                  builder: (context, state) {
                    if (state is AttendanceLoaded) {
                      return ListView.builder(
                          itemCount: _controller.text.isNotEmpty
                              ? filtredStudents.length
                              : widget.students.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            final student = _controller.text.isNotEmpty
                                ? filtredStudents[index]
                                : widget.students[index];

                            final attendance = state.attendances
                                .where((e) => e.studentId == student.id);

                            if (_loading) {
                              return ListView(shrinkWrap: true, children: [
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
                              ]);
                            } else {
                              return _user.role == UserRole.parent
                                  ? ParentAttendanceTile(
                                      student,
                                      attendance: attendance.firstOrNull,
                                      onChange: () {
                                        Future.delayed(
                                            const Duration(milliseconds: 250),
                                            () {
                                          _attendanceCubit
                                              .fetchAttendanceByDate(
                                                  _selectedDate);
                                        });
                                      },
                                    )
                                  : StudentAttendanceTile(
                                      student,
                                      selectedDate: _selectedDate,
                                      attendance: attendance.firstOrNull,
                                      onChange: () {
                                        _attendanceCubit.fetchAttendanceByDate(
                                            _selectedDate);
                                      },
                                    );
                            }
                          });
                    } else {
                      return ListView(shrinkWrap: true, children: [
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
                      ]);
                    }
                  }),
            ),
          ),
        ],
      ),
    );
  }
}
