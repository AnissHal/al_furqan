import 'package:al_furqan/application/auth/auth_cubit.dart';
import 'package:al_furqan/application/student/crud/student_cubit.dart';
import 'package:al_furqan/models/users.dart';
import 'package:al_furqan/screens/file/file_screen.dart';
import 'package:al_furqan/screens/presence/presence_screen.dart';
import 'package:al_furqan/screens/school_screen.dart';
import 'package:al_furqan/screens/student/student_list_view.dart';
import 'package:al_furqan/screens/teacher/teacher_manage.dart';
import 'package:al_furqan/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';

class ParentDashboardGrid extends StatefulWidget {
  const ParentDashboardGrid({super.key});

  @override
  State<ParentDashboardGrid> createState() => _ParentDashboardGridState();
}

class _ParentDashboardGridState extends State<ParentDashboardGrid> {
  late Users? _userData;
  @override
  void initState() {
    super.initState();
    final Users? userData =
        (context.read<AuthCubit>().state as UserAuthenticated).userData;
    _userData = userData;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is UserAuthenticated) {
          setState(() {
            _userData = state.userData;
          });
        }
      },
      child: Column(
        children: [
          if (_userData != null)
            Expanded(
              child: GridView.custom(
                padding: const EdgeInsets.all(8),
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2),
                childrenDelegate: SliverChildListDelegate([
                  InkWell(
                    onTap: () {
                      Navigator.of(context)
                          .push(MaterialPageRoute(
                              builder: (context) => const StudentListScreen()))
                          .then((_) {
                        context.read<StudentCubit>().disposeStream();
                      });
                    },
                    child: Card.filled(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                              child: Lottie.asset(
                                  "assets/lottie/man_kid_quran.json",
                                  frameRate: const FrameRate(15))),
                          Text(
                            context.loc.students,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) =>
                              const TeacherManageDashboard()));
                    },
                    child: Card.filled(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                              child: Lottie.asset(
                                  "assets/lottie/man_quran1.json",
                                  frameRate: const FrameRate(15))),
                          Text(
                            context.loc.teachers,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const SchoolScreen()));
                    },
                    child: Card.filled(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                              child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.asset('assets/ui/mosque.png'),
                          )),
                          Text(
                            context.loc.school,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const PresenceScreen()));
                    },
                    child: Card.filled(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                              child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.asset('assets/ui/attendance.png'),
                          )),
                          Text(
                            context.loc.attendance,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const FileScreen()));
                    },
                    child: Card.filled(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                              child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.asset('assets/ui/file.png'),
                          )),
                          Text(
                            context.loc.files,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                  ),
                ]),
              ),
            ),
        ],
      ),
    );
  }
}
