import 'package:al_furqan/application/student/manage/student_manage_cubit.dart';
import 'package:al_furqan/models/quran_status.dart';
import 'package:al_furqan/screens/manage/qurandialog.dart';
import 'package:al_furqan/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';

class QuranPage extends StatefulWidget {
  final StudentManageCubit cubit;
  const QuranPage({super.key, required this.cubit});

  @override
  State<QuranPage> createState() => _QuranPageState();
}

class _QuranPageState extends State<QuranPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final manageCubit = widget.cubit;
    final dataColumns = [
      DataColumn(label: Text(context.loc.from_surah)),
      DataColumn(label: Text(context.loc.from_ayah)),
      // DataColumn(label: Text(context.loc.to_surah)),
      DataColumn(label: Text(context.loc.to_ayah)),
      DataColumn(label: Text(context.loc.mark)),
    ];
    return Stack(
      fit: StackFit.expand,
      children: [
        Center(
          child: RefreshIndicator(
            onRefresh: () async {
              manageCubit.refreshProgression();
            },
            child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(children: [
                      BlocBuilder<StudentManageCubit, StudentManageState>(
                          bloc: manageCubit,
                          builder: (context, state) {
                            if (state is StudentManageLoaded) {
                              final quran = manageCubit.getQuranList();
                              if (quran != null && quran.isNotEmpty) {
                                return Column(
                                  children: [
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Expanded(
                                            child: Container(
                                              margin:
                                                  const EdgeInsetsDirectional
                                                      .symmetric(horizontal: 8),
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                color: Colors.green,
                                              ),
                                              child: Center(
                                                  child: Text(
                                                context.loc.memorization,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium!
                                                    .copyWith(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .onSurface,
                                                        fontSize: 18),
                                              )),
                                            ),
                                          ),
                                          Expanded(
                                            child: Container(
                                              margin:
                                                  const EdgeInsetsDirectional
                                                      .symmetric(horizontal: 8),
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                color: Colors.teal,
                                              ),
                                              child: Center(
                                                  child: Text(
                                                context.loc.revision,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium!
                                                    .copyWith(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .onSurface,
                                                        fontSize: 18),
                                              )),
                                            ),
                                          ),
                                        ]),
                                    PaginatedDataTable(
                                      columns: dataColumns,
                                      columnSpacing: 24,
                                      source: QuranStatusDataSource(
                                          quran, context, manageCubit),
                                    ),
                                  ],
                                );
                              }
                              return Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Lottie.asset(
                                      'assets/lottie/man_kid_quran.json',
                                      frameRate: const FrameRate(20)),
                                  Text(context.loc.no_progress_yet),
                                ],
                              );
                            } else {
                              return const CircularProgressIndicator();
                            }
                          })
                    ]))),
          ),
        ),
        Positioned(
            bottom: 8,
            right: 8,
            child: InkWell(
              onTap: () async {
                // showdialog
                showDialog(
                        context: context,
                        builder: (context) => QuranDialog(cubit: manageCubit))
                    .then((_) {
                  manageCubit.refreshProgression();
                });
              },
              child: CircleAvatar(
                radius: 28,
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: const Icon(
                  Icons.add,
                  size: 36,
                ),
              ),
            ))
      ],
    );
  }
}

class QuranStatusDataSource extends DataTableSource {
  final List<QuranItem> data;
  final BuildContext context;
  final StudentManageCubit manageCubit;

  QuranStatusDataSource(this.data, this.context, this.manageCubit);

  @override
  DataRow? getRow(int index) {
    return DataRow(
        onLongPress: () {
          showDialog(
              context: context,
              builder: (context) => QuranDialog(
                  cubit: manageCubit,
                  item: data[index],
                  index: index)).then((_) {
            manageCubit.refreshProgression();
          });
        },
        color:
            WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
          if (data[index].type == ItemType.reading) {
            return Colors.green;
          } else if (data[index].type == ItemType.revision) {
            return Colors.teal;
          }
          return null; // Use default value for other states and null if not needed.
        }),
        cells: [
          DataCell(Text(data[index].fromQuranStatus.titleAr)),
          DataCell(Text(data[index].fromAyah.toString())),
          // DataCell(Text(data[index].toQuranStatus.titleAr)),
          DataCell(Text(data[index].toAyah.toString())),
          DataCell(Text(data[index].note.toString())),
        ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => data.length;

  @override
  int get selectedRowCount => 0;
}
