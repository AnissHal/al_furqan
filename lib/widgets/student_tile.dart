import 'package:al_furqan/application/auth/auth_cubit.dart';
import 'package:al_furqan/application/services/asset_service.dart';
import 'package:al_furqan/application/services/student_service.dart';
import 'package:al_furqan/application/student/attendance/attendance_cubit.dart';
import 'package:al_furqan/screens/student/student_manage_view.dart';
import 'package:al_furqan/utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/student.dart';

class StudentTile extends StatelessWidget {
  final Student student;

  const StudentTile(this.student, {super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => StudentManageView(
                  student: student,
                )));
      },
      onLongPress: () {
        // confirm delete student alertdialog
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: Text(context.loc.delete_student),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(context.loc.cancel)),
                    TextButton(
                        onPressed: () {
                          StudentService.removeStudent(student.id).then((_) {
                            Navigator.of(context).pop();
                          });
                        },
                        child: Text(context.loc.remove)),
                  ],
                ));
      },
      child: Card.outlined(
        child: Dismissible(
          key: Key(student.id),
          background: Container(
            decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Colors.green, Colors.red])),
            child: Row(
              children: [
                IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.event_busy, color: Colors.white)),
                const Spacer(),
                IconButton(
                    onPressed: () {},
                    icon:
                        const Icon(Icons.event_available, color: Colors.white)),
              ],
            ),
          ),
          confirmDismiss: (direction) async {
            final teacherId =
                (context.read<AuthCubit>().state as UserAuthenticated)
                    .supabaseUser
                    .id;
            if (direction == DismissDirection.startToEnd) {
              AttendanceCubit()
                  .markAbsent(student.id, teacherId, DateTime.now())
                  .then((_) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(context.loc.marked_as_absent),
                  backgroundColor: Colors.red,
                ));
              });
            } else {
              AttendanceCubit()
                  .markPresent(student.id, teacherId, DateTime.now())
                  .then((_) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(context.loc.marked_as_present),
                  backgroundColor: Colors.green,
                ));
              });
            }
            return null;
          },
          child: ListTile(
            leading: CircleAvatar(
              foregroundImage: student.image == null
                  ? null
                  : CachedNetworkImageProvider(
                      AssetService.composeStudentImageURL(student),
                    ),
              child: student.image == null
                  ? Text(student.fullName[0].toUpperCase())
                  : null,
            ),
            title: Text(student.fullName),
            subtitle: Text(student.age.toString()),
          ),
        ),
      ),
    );
  }
}
