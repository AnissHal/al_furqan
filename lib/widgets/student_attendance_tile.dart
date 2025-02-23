import 'package:al_furqan/application/auth/auth_cubit.dart';
import 'package:al_furqan/application/services/asset_service.dart';
import 'package:al_furqan/application/student/attendance/attendance_cubit.dart';
import 'package:al_furqan/models/attendance.dart';
import 'package:al_furqan/models/users.dart';
import 'package:al_furqan/utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/student.dart';

class StudentAttendanceTile extends StatefulWidget {
  final Student student;
  final Attendance? attendance;
  final Function? onChange;
  final DateTime selectedDate;

  const StudentAttendanceTile(this.student,
      {super.key, this.attendance, this.onChange, required this.selectedDate});

  @override
  State<StudentAttendanceTile> createState() => _StudentAttendanceTileState();
}

class _StudentAttendanceTileState extends State<StudentAttendanceTile> {
  final _attendanceCubit = AttendanceCubit();
  late Users user;

  @override
  void initState() {
    user = (context.read<AuthCubit>().state as UserAuthenticated).userData!;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card.outlined(
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              foregroundImage: widget.student.image == null
                  ? null
                  : CachedNetworkImageProvider(
                      AssetService.composeStudentImageURL(widget.student),
                    ),
              child: widget.student.image == null
                  ? Text(widget.student.fullName[0].toUpperCase())
                  : null,
            ),
            title: Text(widget.student.fullName),
            subtitle: Text(widget.student.age.toString()),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: (widget.attendance != null &&
                          widget.attendance!.status == AttendanceStatus.absent)
                      ? () {
                          _attendanceCubit
                              .removeAttendance(widget.attendance!.id)
                              .then((_) {
                            if (widget.onChange != null) {
                              widget.onChange!();
                            }
                          });
                        }
                      : () {
                          _attendanceCubit
                              .markAbsent(widget.student.id, user.id,
                                  widget.selectedDate)
                              .then((_) {
                            if (widget.onChange != null) {
                              widget.onChange!();
                            }
                          });
                        },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: (widget.attendance != null &&
                                  widget.attendance!.status ==
                                      AttendanceStatus.absent) ||
                              widget.attendance == null
                          ? Colors.red
                          : Colors.grey),
                  child: Text(context.loc.absent),
                ),
              ),
              const SizedBox(
                width: 8,
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: (widget.attendance != null &&
                          widget.attendance!.status == AttendanceStatus.present)
                      ? () {
                          _attendanceCubit
                              .removeAttendance(widget.attendance!.id)
                              .then((_) {
                            if (widget.onChange != null) {
                              widget.onChange!();
                            }
                          });
                        }
                      : () {
                          _attendanceCubit
                              .markPresent(widget.student.id, user.id,
                                  widget.selectedDate)
                              .then((_) {
                            if (widget.onChange != null) {
                              widget.onChange!();
                            }
                          });
                        },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: (widget.attendance != null &&
                                  widget.attendance!.status ==
                                      AttendanceStatus.present) ||
                              widget.attendance == null
                          ? Colors.green
                          : Colors.grey),
                  child: Text(context.loc.present),
                ),
              ),
              const SizedBox(
                width: 8,
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: (widget.attendance != null &&
                          widget.attendance!.status == AttendanceStatus.late)
                      ? () {
                          _attendanceCubit
                              .removeAttendance(widget.attendance!.id)
                              .then((_) {
                            if (widget.onChange != null) {
                              widget.onChange!();
                            }
                          });
                        }
                      : () {
                          _attendanceCubit
                              .markLate(widget.student.id, user.id,
                                  widget.selectedDate)
                              .then((_) {
                            if (widget.onChange != null) {
                              widget.onChange!();
                            }
                          });
                        },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: (widget.attendance != null &&
                                  widget.attendance!.status ==
                                      AttendanceStatus.late) ||
                              widget.attendance == null
                          ? Colors.amber
                          : Colors.grey),
                  child: Text(context.loc.late),
                ),
              ),
              const SizedBox(
                width: 6,
              ),
              if (widget.attendance != null)
                InkWell(
                  onTap: (widget.attendance != null)
                      ? () {
                          _attendanceCubit
                              .removeAttendance(widget.attendance!.id)
                              .then((_) {
                            if (widget.onChange != null) {
                              widget.onChange!();
                            }
                          });
                        }
                      : null,
                  child: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.error,
                    child: Icon(Icons.close,
                        color: Theme.of(context).colorScheme.onError),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class ParentAttendanceTile extends StatefulWidget {
  final Student student;
  final Attendance? attendance;
  final Function? onChange;

  const ParentAttendanceTile(this.student,
      {super.key, this.attendance, this.onChange});

  @override
  State<ParentAttendanceTile> createState() => _ParentAttendanceTileState();
}

class _ParentAttendanceTileState extends State<ParentAttendanceTile> {
  late Users user;

  @override
  void initState() {
    user = (context.read<AuthCubit>().state as UserAuthenticated).userData!;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card.outlined(
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              foregroundImage: widget.student.image == null
                  ? null
                  : CachedNetworkImageProvider(
                      AssetService.composeStudentImageURL(widget.student),
                    ),
              child: widget.student.image == null
                  ? Text(widget.student.fullName[0].toUpperCase())
                  : null,
            ),
            title: Text(widget.student.fullName),
            subtitle: Text(widget.student.age.toString()),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.all(8),
                child: Container(
                  decoration: BoxDecoration(
                    color: switch (widget.attendance?.status) {
                      null => Theme.of(context).colorScheme.surface,
                      AttendanceStatus.present => Colors.green,
                      AttendanceStatus.absent => Colors.red,
                      AttendanceStatus.late => Colors.amber,
                      AttendanceStatus.excused => Colors.yellow
                    },
                  ),
                  child: switch (widget.attendance?.status) {
                    null => Center(
                        child: Text(context.loc.no_presence,
                            style: Theme.of(context).textTheme.bodyLarge),
                      ),
                    AttendanceStatus.present => Center(
                        child: Text(
                          context.loc.present,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    AttendanceStatus.absent => Center(
                        child: Text(
                          context.loc.absent,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    AttendanceStatus.late => Center(
                        child: Text(
                          context.loc.late,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    AttendanceStatus.excused => Center(
                        child: Text(
                          context.loc.excused,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      )
                  },
                ),
              ))
            ],
          ),
        ],
      ),
    );
  }
}
