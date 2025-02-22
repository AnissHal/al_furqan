import 'dart:convert';

import 'package:al_furqan/application/enums/encouragement.dart';
import 'package:al_furqan/application/services/asset_service.dart';
import 'package:al_furqan/application/services/teacher_service.dart';
import 'package:al_furqan/application/student/attendance/attendance_cubit.dart';
import 'package:al_furqan/application/student/manage/student_manage_cubit.dart';
import 'package:al_furqan/models/attendance.dart';
import 'package:al_furqan/models/quran_status.dart';
import 'package:al_furqan/models/student.dart';
import 'package:al_furqan/models/teacher.dart';
import 'package:al_furqan/screens/badge_screen.dart';
import 'package:al_furqan/screens/view/mutn_view_page.dart';
import 'package:al_furqan/screens/view/quran_view_page.dart';
import 'package:al_furqan/utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class StudentView extends StatefulWidget {
  final Student student;
  const StudentView(
    this.student, {
    super.key,
  });

  @override
  State<StudentView> createState() => _StudentViewState();
}

class _StudentViewState extends State<StudentView> {
  final _studentManageCubit = StudentManageCubit();
  final _attendanceCubit = AttendanceCubit();

  @override
  void initState() {
    super.initState();
    _studentManageCubit.watchStudent(widget.student.id);
    _attendanceCubit.getttendance(widget.student.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
              child: BlocBuilder<StudentManageCubit, StudentManageState>(
            bloc: _studentManageCubit,
            builder: (context, state) {
              if (state is StudentManageLoaded) {
                final mutns = _studentManageCubit.getMutnList();
                final qurans = _studentManageCubit.getQuranList();

                return Column(
                  children: [
                    Card.filled(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 32),
                        child: Column(
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * .3,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary)),
                              child: AspectRatio(
                                aspectRatio: 1,
                                child: state.student.image == null ||
                                        state.student.image!.isEmpty
                                    ? const CircleAvatar(
                                        child: Icon(
                                          Icons.person,
                                          size: 64,
                                        ),
                                      )
                                    : CircleAvatar(
                                        foregroundImage:
                                            CachedNetworkImageProvider(
                                                AssetService
                                                    .composeStudentImageURL(
                                                        state.student)),
                                      ),
                              ),
                            ),
                            Text(
                              state.student.fullName,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 8),
                            Row(children: [
                              Expanded(
                                child: Text(context.loc.age,
                                    style:
                                        Theme.of(context).textTheme.bodyLarge),
                              ),
                              Expanded(
                                child: Text(state.student.age.toString(),
                                    style:
                                        Theme.of(context).textTheme.bodyLarge),
                              ),
                            ]),
                            const SizedBox(height: 8),
                            Row(children: [
                              Expanded(
                                child: Text(context.loc.phone,
                                    style:
                                        Theme.of(context).textTheme.bodyLarge),
                              ),
                              Expanded(
                                child: Text(state.student.phone,
                                    style:
                                        Theme.of(context).textTheme.bodyLarge),
                              ),
                            ]),
                            const SizedBox(
                              height: 8,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                InkWell(
                                  onTap: () async {
                                    await showDialog(
                                      context: context,
                                      builder: (context) {
                                        return Dialog(
                                          backgroundColor: Colors.white,
                                          child: AspectRatio(
                                            aspectRatio: 1,
                                            child: Center(
                                              child: QrImageView(
                                                data: jsonEncode(
                                                    {'id': state.student.id}),
                                                size: 256,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  child: Column(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        child: IconButton(
                                          onPressed: null,
                                          icon: Icon(
                                            Icons.qr_code,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onPrimary,
                                          ),
                                        ),
                                      ),
                                      const Text("QR")
                                    ],
                                  ),
                                ),
                                Column(
                                  children: [
                                    InkWell(
                                      onTap: () {},
                                      child: CircleAvatar(
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        child: IconButton(
                                          onPressed: () {
                                            Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        BadgeScreen(
                                                          avatar: widget.student
                                                                      .image ==
                                                                  null
                                                              ? null
                                                              : AssetService.getAvatarPublicUrl(
                                                                  widget.student
                                                                      .image!,
                                                                  widget.student
                                                                      .schoolId),
                                                          student:
                                                              widget.student,
                                                        )));
                                          },
                                          icon: Icon(
                                            Icons.badge,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onPrimary,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Text(context.loc.badge)
                                  ],
                                ),
                              ],
                            ),
                            if (state.student.mark != null)
                              Container(
                                width: MediaQuery.of(context).size.width * .95,
                                margin: const EdgeInsets.all(8),
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primaryContainer,
                                    borderRadius: BorderRadius.circular(8)),
                                child: Center(
                                  child: Column(
                                    children: [
                                      Text(context.loc.mark),
                                      Text(
                                        "${state.student.mark}/20",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .copyWith(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 24,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimaryContainer),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            Row(
                              children: [
                                if (state.student.encouragement != null)
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondaryContainer,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Column(
                                        children: [
                                          Text(context.loc.encouragement,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                          Text(
                                              translateEncouragement(
                                                  state.student.encouragement!),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge!
                                                  .copyWith(
                                                      fontWeight:
                                                          FontWeight.bold))
                                        ],
                                      ),
                                    ),
                                  ),
                                const SizedBox(width: 8),
                                if (state.student.behaviour != null)
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondaryContainer,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Column(
                                        children: [
                                          Text(context.loc.behaviour,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                          Text(
                                              translateBehaviour(
                                                  state.student.behaviour!),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge!
                                                  .copyWith(
                                                      fontWeight:
                                                          FontWeight.bold))
                                        ],
                                      ),
                                    ),
                                  )
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    if (state.student.requested == true)
                      Container(
                        width: MediaQuery.of(context).size.width * .95,
                        margin: const EdgeInsets.all(8),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.errorContainer,
                            borderRadius: BorderRadius.circular(8)),
                        child: Center(
                          child: FutureBuilder<Teacher?>(
                              future: TeacherService.findById(
                                  state.student.teacherId),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return Text(
                                    "${context.loc.being_requested} ${snapshot.data!.name}",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 24,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onErrorContainer),
                                  );
                                }
                                if (snapshot.hasError) {}
                                return const CircularProgressIndicator();
                              }),
                        ),
                      ),
                    ...[
                      Text(
                        context.loc.quran,
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            fontWeight: FontWeight.bold, fontSize: 24),
                      ),
                      SizedBox(
                          width: MediaQuery.of(context).size.width * .95,
                          child: Column(children: [
                            if (qurans != null)
                              InkWell(
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => QuranViewPage(
                                            items: qurans.reversed.toList(),
                                          )));
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                        "${context.loc.show_all} (${qurans.length})"),
                                    const Icon(Icons.arrow_forward)
                                  ],
                                ),
                              ),
                            Card.outlined(
                              color: qurans != null
                                  ? Theme.of(context).colorScheme.inverseSurface
                                  : null,
                              child: qurans != null
                                  ? Column(
                                      children: [
                                        Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          decoration: BoxDecoration(
                                            color: qurans != null
                                                ? qurans.last.type ==
                                                        ItemType.revision
                                                    ? Colors.teal
                                                    : Colors.green
                                                : null,
                                            borderRadius:
                                                const BorderRadius.only(
                                                    topLeft: Radius.circular(4),
                                                    topRight:
                                                        Radius.circular(4),
                                                    bottomLeft:
                                                        Radius.circular(24),
                                                    bottomRight:
                                                        Radius.circular(24)),
                                          ),
                                          child: Center(
                                            child: Text(
                                              qurans.last.type ==
                                                      ItemType.revision
                                                  ? qurans.last.toAyah ==
                                                              qurans
                                                                  .last
                                                                  .fromQuranStatus
                                                                  .count &&
                                                          qurans.last
                                                                  .fromAyah ==
                                                              1
                                                      ? context.loc
                                                          .full_surah_revision
                                                      : context.loc.revision
                                                  : qurans.last.toAyah ==
                                                              qurans
                                                                  .last
                                                                  .fromQuranStatus
                                                                  .count &&
                                                          qurans.last
                                                                  .fromAyah ==
                                                              1
                                                      ? context.loc
                                                          .full_surah_memorization
                                                      : context
                                                          .loc.memorization,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headlineSmall!
                                                  .copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black),
                                            ),
                                          ),
                                        ),
                                        Text(
                                          "${context.loc.surah} ${qurans.last.fromQuranStatus.titleAr}",
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineSmall!
                                              .copyWith(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onInverseSurface),
                                        ),
                                        if (!(qurans.last.toAyah ==
                                                qurans.last.fromQuranStatus
                                                    .count &&
                                            qurans.last.fromAyah == 1))
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Column(children: [
                                                  Text(
                                                    "${context.loc.from_ayah} ${qurans.last.fromAyah.toString()}",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyLarge!
                                                        .copyWith(
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .onInverseSurface),
                                                  )
                                                ]),
                                              ),
                                              Icon(Icons.arrow_forward,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onInverseSurface),
                                              Expanded(
                                                child: Column(children: [
                                                  Text(
                                                    "${context.loc.to_ayah} ${qurans.last.toAyah.toString()}",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyLarge!
                                                        .copyWith(
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .onInverseSurface),
                                                  ),
                                                ]),
                                              ),
                                            ],
                                          ),
                                        const SizedBox(
                                          height: 12,
                                        ),
                                        Text(
                                          "${context.loc.mark} ${qurans.last.note.toString()}/20",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge!
                                              .copyWith(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onInverseSurface),
                                        )
                                      ],
                                    )
                                  : Center(
                                      child: Text(context.loc.no_progress_yet,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge!),
                                    ),
                            )
                          ])),
                      Text(
                        context.loc.mutn,
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            fontWeight: FontWeight.bold, fontSize: 24),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * .95,
                        child: Column(
                          children: [
                            if (mutns != null)
                              InkWell(
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => MutnViewPage(
                                            items: mutns.reversed.toList(),
                                          )));
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                        "${context.loc.show_all} (${mutns.length})"),
                                    const Icon(Icons.arrow_forward)
                                  ],
                                ),
                              ),
                            Card.outlined(
                              color: mutns != null
                                  ? Theme.of(context).colorScheme.inverseSurface
                                  : null,
                              child: mutns != null
                                  ? Column(
                                      children: [
                                        Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          decoration: BoxDecoration(
                                            color: mutns != null
                                                ? mutns.last.type ==
                                                        ItemType.revision
                                                    ? Colors.teal
                                                    : Colors.green
                                                : null,
                                            borderRadius:
                                                const BorderRadius.only(
                                                    topLeft: Radius.circular(4),
                                                    topRight:
                                                        Radius.circular(4),
                                                    bottomLeft:
                                                        Radius.circular(24),
                                                    bottomRight:
                                                        Radius.circular(24)),
                                          ),
                                          child: Center(
                                            child: Text(
                                              mutns.last.type ==
                                                      ItemType.revision
                                                  ? mutns.last.to ==
                                                              mutns
                                                                  .last
                                                                  .fromMutn
                                                                  .count &&
                                                          mutns.last.from == 1
                                                      ? context.loc
                                                          .full_mutn_revision
                                                      : context.loc.revision
                                                  : mutns.last.to ==
                                                              mutns
                                                                  .last
                                                                  .fromMutn
                                                                  .count &&
                                                          mutns.last.from == 1
                                                      ? context.loc
                                                          .full_mutn_memorization
                                                      : context
                                                          .loc.memorization,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headlineSmall!
                                                  .copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black),
                                            ),
                                          ),
                                        ),
                                        Text(
                                          mutns.last.fromMutn.titleAr,
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineSmall!
                                              .copyWith(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onInverseSurface),
                                        ),
                                        if (!(mutns.last.to ==
                                                mutns.last.fromMutn.count &&
                                            mutns.last.from == 1))
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Column(children: [
                                                  Text(
                                                    "${context.loc.from_page} ${mutns.last.from.toString()}",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyLarge!
                                                        .copyWith(
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .onInverseSurface),
                                                  )
                                                ]),
                                              ),
                                              Icon(Icons.arrow_forward,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onInverseSurface),
                                              Expanded(
                                                child: Column(children: [
                                                  Text(
                                                    "${context.loc.to_page} ${mutns.last.to.toString()}",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyLarge!
                                                        .copyWith(
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .onInverseSurface),
                                                  ),
                                                ]),
                                              ),
                                            ],
                                          ),
                                        const SizedBox(
                                          height: 12,
                                        ),
                                        Text(
                                          "${context.loc.mark} ${mutns.last.note.toString()}/20",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge!
                                              .copyWith(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onInverseSurface),
                                        )
                                      ],
                                    )
                                  : Center(
                                      child: Text(context.loc.no_progress_yet,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    Text(
                      context.loc.attendance,
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge!
                          .copyWith(fontWeight: FontWeight.bold, fontSize: 24),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: Container(
                            margin: const EdgeInsetsDirectional.symmetric(
                                horizontal: 8),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.green,
                            ),
                            child: Center(
                                child: Text(
                              context.loc.present,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                      fontSize: 18),
                            )),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            margin: const EdgeInsetsDirectional.symmetric(
                                horizontal: 8),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.amber,
                            ),
                            child: Center(
                                child: Text(
                              context.loc.late,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                      fontSize: 18),
                            )),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            margin: const EdgeInsetsDirectional.symmetric(
                                horizontal: 8),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.red,
                            ),
                            child: Center(
                                child: Text(
                              context.loc.absent,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                      fontSize: 18),
                            )),
                          ),
                        ),
                      ],
                    ),
                    BlocBuilder<AttendanceCubit, AttendanceState>(
                      bloc: _attendanceCubit,
                      builder: (context, state) {
                        return SfCalendar(
                          view: CalendarView.month,
                          dataSource: state is AttendanceLoaded
                              ? _attendanceCubit
                                  .getCalendarDataSource(state.attendances)
                              : null,
                          monthCellBuilder: (context, details) {
                            return Container(
                                margin: const EdgeInsets.all(4.0),
                                decoration: BoxDecoration(
                                    color: details.appointments.isNotEmpty
                                        ? switch ((details.appointments.first
                                                as Attendance)
                                            .status) {
                                            AttendanceStatus.absent =>
                                              Colors.red,
                                            AttendanceStatus.late =>
                                              Colors.amber,
                                            AttendanceStatus.excused =>
                                              Colors.yellow,
                                            AttendanceStatus.present =>
                                              Colors.green,
                                          }
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(10.0)),
                                child: Center(
                                  child: Text(
                                    details.date.day.toString(),
                                    style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ));
                          },
                          monthViewSettings: const MonthViewSettings(
                            showTrailingAndLeadingDates: false,
                            appointmentDisplayMode:
                                MonthAppointmentDisplayMode.none,
                          ),
                        );
                      },
                    ),
                  ],
                );
              }
              if (state is StudentManageError) {
                return Center(
                    child: Text(
                  state.message,
                  textDirection: TextDirection.ltr,
                ));
              }
              return const Center(child: CircularProgressIndicator());
            },
          )),
        ),
      ),
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
}
