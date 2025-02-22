import 'package:al_furqan/application/auth/auth_cubit.dart';
import 'package:al_furqan/application/student/attendance/attendance_cubit.dart';
import 'package:al_furqan/models/attendance.dart';
import 'package:al_furqan/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class AttendanceWidget extends StatefulWidget {
  const AttendanceWidget({super.key, required this.studentId});
  final String studentId;

  @override
  State<AttendanceWidget> createState() => _AttendanceWidgetState();
}

class _AttendanceWidgetState extends State<AttendanceWidget> {
  final _attendanceCubit = AttendanceCubit();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AttendanceCubit, AttendanceState>(
      bloc: _attendanceCubit..watchAttendance(widget.studentId),
      builder: (context, state) {
        if (state is AttendanceLoaded) {
          return SfCalendar(
            view: CalendarView.month,
            dataSource:
                _attendanceCubit.getCalendarDataSource(state.attendances),
            monthCellBuilder: (context, details) {
              return Container(
                  margin: const EdgeInsets.all(4.0),
                  decoration: BoxDecoration(
                      color: details.appointments.isNotEmpty
                          ? switch ((details.appointments.first as Attendance)
                              .status) {
                              AttendanceStatus.absent => Colors.red,
                              AttendanceStatus.late => Colors.amber,
                              AttendanceStatus.present => Colors.green,
                              AttendanceStatus.excused => Colors.yellow,
                            }
                          : Colors.white,
                      borderRadius: BorderRadius.circular(10.0)),
                  child: Center(
                    child: Text(
                      details.date.day.toString(),
                      style: const TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                  ));
            },
            monthViewSettings: const MonthViewSettings(
              showTrailingAndLeadingDates: false,
              appointmentDisplayMode: MonthAppointmentDisplayMode.none,
            ),
            onLongPress: (d) {
              showDialog(
                  context: context,
                  builder: (context) {
                    final studentId = widget.studentId;
                    final teacherId =
                        (context.read<AuthCubit>().state as UserAuthenticated)
                            .supabaseUser
                            .id;
                    return Dialog(
                        child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          // format date as tuesday 23 april 2024 in current locale
                          DateFormat(
                                  'E dd MMMM yyyy',
                                  Localizations.localeOf(context)
                                      .toLanguageTag())
                              .format(d.date!),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                        if (d.appointments!.isNotEmpty) ...[
                          // format date
                          Container(
                              margin: const EdgeInsets.all(8.0),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                  color: switch (
                                      (d.appointments!.first as Attendance)
                                          .status) {
                                    AttendanceStatus.absent => Colors.red,
                                    AttendanceStatus.late => Colors.amber,
                                    AttendanceStatus.excused => Colors.yellow,
                                    AttendanceStatus.present => Colors.green,
                                  },
                                  borderRadius: BorderRadius.circular(10.0)),
                              child: Center(
                                  child: Text(
                                "${(d.appointments!.first as Attendance).status}",
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              )))
                        ],
                        Text(context.loc.attendance,
                            style: Theme.of(context).textTheme.headlineSmall),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  _attendanceCubit
                                      .markAbsent(studentId, teacherId, d.date!)
                                      .then((_) {
                                    Navigator.of(context).pop();
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red),
                                child: Text(context.loc.absent),
                              ),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  _attendanceCubit
                                      .markPresent(
                                          studentId, teacherId, d.date!)
                                      .then((_) {
                                    Navigator.of(context).pop();
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green),
                                child: Text(context.loc.present),
                              ),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  _attendanceCubit
                                      .markLate(studentId, teacherId, d.date!)
                                      .then((_) {
                                    Navigator.of(context).pop();
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.amber),
                                child: Text(context.loc.late),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue),
                              child: Text(context.loc.cancel),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                if (d.appointments!.isNotEmpty) {
                                  _attendanceCubit
                                      .removeAttendance(d.appointments![0].id!)
                                      .then((_) {
                                    Navigator.of(context).pop();
                                  });
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.black),
                              child: Text(context.loc.remove_attendance),
                            )
                          ],
                        ),
                      ],
                    ));
                  });
            },
          );
        }

        if (state is AttendanceError) {
          return Center(
            child: Text(state.message),
          );
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
