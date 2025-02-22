import 'package:al_furqan/application/enums/encouragement.dart';
import 'package:al_furqan/application/student/manage/student_manage_cubit.dart';
import 'package:al_furqan/models/student.dart';
import 'package:al_furqan/screens/manage/mutn_page.dart';
import 'package:al_furqan/screens/manage/quran_page.dart';
import 'package:al_furqan/screens/student/student_add_view.dart';
import 'package:al_furqan/utils.dart';
import 'package:al_furqan/widgets/student_manage_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StudentManageView extends StatefulWidget {
  final Student student;
  const StudentManageView({super.key, required this.student});

  @override
  State<StudentManageView> createState() => _StudentManageViewState();
}

class _StudentManageViewState extends State<StudentManageView> {
  final TextEditingController _markController = TextEditingController();

  final StudentManageCubit _manageCubit = StudentManageCubit();

  Encouragement? _encouragement;
  Behaviour? _behaviour;

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _manageCubit.watchStudent(widget.student.id);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<StudentManageCubit, StudentManageState>(
      bloc: _manageCubit,
      listener: (context, state) {
        if (state is StudentManageLoaded) {
          setState(() {
            _markController.text =
                state.student.mark != null ? state.student.mark.toString() : '';
            _encouragement = state.student.encouragement;
            _behaviour = state.student.behaviour;
          });
        }
      },
      child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            title: Text(context.loc.student_manage),
            actions: [
              BlocBuilder<StudentManageCubit, StudentManageState>(
                bloc: _manageCubit,
                builder: (context, state) {
                  if (state is StudentManageLoaded) {
                    return IconButton(
                        onPressed: () {
                          Navigator.of(context)
                              .push(MaterialPageRoute(
                                  builder: (context) => StudentAddView(
                                        student: state.student,
                                        studentManageCubit: _manageCubit,
                                      )))
                              .then((_) {});
                        },
                        icon: const Icon(Icons.edit));
                  }
                  return Container();
                },
              )
            ],
          ),
          body: IndexedStack(
            index: _currentIndex,
            children: [
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      StudentManageHeader(
                          cubit: _manageCubit, student: widget.student),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          context.loc.observation,
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium!
                              .copyWith(
                                  fontWeight: FontWeight.bold,
                                  color:
                                      Theme.of(context).colorScheme.onSurface),
                        ),
                      ),
                      Card.filled(
                          child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            child: TextFormField(
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              controller: _markController,
                              inputFormatters: [
                                // accept only mark like 19.5 max 20
                                FilteringTextInputFormatter.allow(
                                  RegExp(
                                      r'^[0-9.,-]*$'), // Allow numbers, `,`, `.` and `-`.
                                ),
                              ],
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(),
                                labelText: context.loc.mark,
                                hintText: context.loc.mark,
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              validator: (value) {
                                if (value != null && value.isNotEmpty) {
                                  try {
                                    final number = double.parse(value);
                                    if (number < 1 || number > 20) {
                                      return context.loc.mark;
                                    }
                                  } catch (e) {
                                    return context
                                        .loc.validation_enter_valid_number;
                                  }
                                }
                                return null;
                              },
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            child: DropdownButtonFormField<Encouragement?>(
                              value: _encouragement,
                              items: [
                                ...Encouragement.values
                                    .map((v) => DropdownMenuItem(
                                          value: v,
                                          child:
                                              Text(translateEncouragement(v)),
                                        )),
                              ],
                              onChanged: (v) {
                                setState(() {
                                  _encouragement = v;
                                });
                              },
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              decoration: InputDecoration(
                                prefixIcon: _encouragement != null
                                    ? IconButton(
                                        icon: const Icon(Icons.clear),
                                        onPressed: () {
                                          setState(() {
                                            _encouragement = null;
                                          });
                                        },
                                      )
                                    : null,
                                border: const OutlineInputBorder(),
                                labelText: context.loc.encouragement,
                                hintText: context.loc.encouragement,
                              ),
                              validator: (value) {
                                if (value != null) {}
                                return null;
                              },
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            child: DropdownButtonFormField<Behaviour?>(
                              value: _behaviour,
                              items: [
                                ...Behaviour.values.map((v) => DropdownMenuItem(
                                      value: v,
                                      child: Text(translateBehaviour(v)),
                                    )),
                              ],
                              onChanged: (v) {
                                setState(() {
                                  _behaviour = v;
                                });
                              },
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              decoration: InputDecoration(
                                prefixIcon: _behaviour != null
                                    ? IconButton(
                                        icon: const Icon(Icons.clear),
                                        onPressed: () {
                                          setState(() {
                                            _behaviour = null;
                                          });
                                        },
                                      )
                                    : null,
                                border: const OutlineInputBorder(),
                                labelText: context.loc.behaviour,
                                hintText: context.loc.behaviour,
                              ),
                              validator: (value) {
                                if (value != null) {}
                                return null;
                              },
                            ),
                          ),
                          ElevatedButton(
                              onPressed: () {
                                try {
                                  double? mark;
                                  if (_markController.text.isEmpty) {
                                    mark = null;
                                  } else {
                                    mark = double.parse(_markController.text
                                        .replaceAll(",", "."));
                                  }

                                  _manageCubit.updateMarkAndObservation(
                                      mark, _encouragement, _behaviour);
                                } catch (e) {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                    content: Text(e.toString()),
                                  ));
                                }
                                FocusManager.instance.primaryFocus?.unfocus();
                              },
                              child: Text(context.loc.save))
                        ],
                      )),
                      // const SizedBox(
                      //   height: 8,
                      // ),
                      // Align(
                      //   alignment: Alignment.centerRight,
                      //   child: Text(
                      //     context.loc.attendance,
                      //     style: Theme.of(context)
                      //         .textTheme
                      //         .headlineMedium!
                      //         .copyWith(
                      //             fontWeight: FontWeight.bold,
                      //             color:
                      //                 Theme.of(context).colorScheme.onSurface),
                      //   ),
                      // ),
                      // AttendanceWidget(studentId: widget.student.id),
                    ],
                  ),
                ),
              ),
              QuranPage(cubit: _manageCubit),
              MutnPage(cubit: _manageCubit),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.home),
                label: context.loc.student,
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.book),
                label: context.loc.quran,
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.book),
                label: context.loc.mutn,
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
            ],
          )),
    );
  }

  String translateBehaviour(Behaviour behaviour) {
    return switch (behaviour) {
      Behaviour.studious => context.loc.behaviour_studious,
      Behaviour.talkative => context.loc.behaviour_talkative,
      Behaviour.unstudious => context.loc.behaviour_unstudious,
      Behaviour.notPraying => context.loc.behaviour_notpraying
    };
  }

  String translateEncouragement(Encouragement encouragement) {
    return switch (encouragement) {
      Encouragement.special => context.loc.encouragement_special,
      Encouragement.keepFocus => context.loc.encouragement_keepfocus,
      Encouragement.successSoon => context.loc.encouragement_sucesssoon,
      Encouragement.makeEffort => context.loc.encouragement_makeeffort,
      Encouragement.godBless => context.loc.encouragement_godbless,
      Encouragement.greatEffort => context.loc.encouragement_greateffort,
      Encouragement.progress => context.loc.encouragement_progress
    };
  }

  @override
  void dispose() {
    _manageCubit.close();
    super.dispose();
  }
}
