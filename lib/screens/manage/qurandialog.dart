import 'package:al_furqan/application/services/json_service.dart';
import 'package:al_furqan/application/student/manage/student_manage_cubit.dart';
import 'package:al_furqan/models/quran_status.dart';
import 'package:al_furqan/utils.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class QuranDialog extends StatefulWidget {
  const QuranDialog({super.key, required this.cubit, this.item, this.index});

  final StudentManageCubit cubit;
  final QuranItem? item;
  final int? index;

  @override
  State<QuranDialog> createState() => _QuranDialogState();
}

class _QuranDialogState extends State<QuranDialog> {
  late Future<List<QuranStatus>> _futureQuranStatus;
  final GlobalKey<FormState> _quranKey = GlobalKey<FormState>();
  final TextEditingController _fromAyahController = TextEditingController();
  final TextEditingController _toAyahController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  QuranStatus? selectedFromQuranStatus;
  // QuranStatus? selectedToQuranStatus;

  bool _fullSurah = false;

  ItemType? selectedQuranItemType;

  @override
  void initState() {
    super.initState();
    _futureQuranStatus = JsonService.loadQuranStatus();
    if (widget.item != null) {
      assert(widget.item != null && widget.index != null);
      final index = widget.index;
      if (index != -1) {
        selectedFromQuranStatus = widget.item!.fromQuranStatus;
        // selectedToQuranStatus = widget.item!.toQuranStatus;
        selectedQuranItemType = widget.item!.type;
        WidgetsBinding.instance.addPostFrameCallback((t) {
          setState(() {
            if (widget.item!.fromAyah == 1 &&
                widget.item!.toAyah == widget.item!.fromQuranStatus.count) {
              _fullSurah = true;
            } else {
              _fullSurah = false;
            }
          });
        });
        _fromAyahController.text = widget.item!.fromAyah.toString();
        _toAyahController.text = widget.item!.toAyah.toString();
        _noteController.text = widget.item!.note.toString();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final manageCubit = widget.cubit;

    return Dialog.fullscreen(
      child: SingleChildScrollView(
        child: Form(
          key: _quranKey,
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  context.loc.from_surah,
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface),
                ),
              ),
              Card.filled(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      FutureBuilder<List<QuranStatus>>(
                          future: _futureQuranStatus,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  DropdownSearch(
                                    popupProps: const PopupProps.dialog(
                                      showSearchBox: true,
                                    ),
                                    clearButtonProps: ClearButtonProps(
                                      isVisible:
                                          selectedFromQuranStatus != null,
                                    ),
                                    selectedItem: selectedFromQuranStatus,
                                    dropdownDecoratorProps:
                                        DropDownDecoratorProps(
                                      dropdownSearchDecoration: InputDecoration(
                                        labelText: context.loc.surah,
                                        border: const OutlineInputBorder(),
                                      ),
                                    ),
                                    dropdownBuilder: (context, selectedItem) {
                                      if (selectedItem == null) {
                                        return Text(context.loc.surah,
                                            style: const TextStyle(
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold));
                                      }
                                      return Text(
                                        selectedItem.titleAr,
                                        style: const TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold),
                                      );
                                    },
                                    itemAsString: (item) => item.titleAr,
                                    onChanged: (value) {
                                      setState(() {
                                        selectedFromQuranStatus = value;
                                      });
                                    },
                                    items: snapshot.data!,
                                    validator: (value) => value == null
                                        ? context.loc.validation_enter_surah
                                        : null,
                                  ),
                                  const SizedBox(height: 8),
                                  if (!_fullSurah)
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextFormField(
                                            autovalidateMode: AutovalidateMode
                                                .onUserInteraction,
                                            controller: _fromAyahController,
                                            decoration: InputDecoration(
                                                suffix: selectedFromQuranStatus !=
                                                        null
                                                    ? IconButton(
                                                        onPressed: () {
                                                          _fromAyahController
                                                                  .text =
                                                              selectedFromQuranStatus!
                                                                  .count
                                                                  .toString();
                                                        },
                                                        icon: const Icon(
                                                            Icons.arrow_upward))
                                                    : null,
                                                prefix: selectedFromQuranStatus !=
                                                        null
                                                    ? IconButton(
                                                        onPressed: () {
                                                          _fromAyahController
                                                              .text = "1";
                                                        },
                                                        icon: const Icon(Icons
                                                            .arrow_downward))
                                                    : null,
                                                border:
                                                    const OutlineInputBorder(),
                                                labelText:
                                                    context.loc.from_ayah,
                                                hintText:
                                                    context.loc.from_ayah),
                                            keyboardType: TextInputType.number,
                                            inputFormatters: <TextInputFormatter>[
                                              FilteringTextInputFormatter
                                                  .digitsOnly
                                            ],
                                            validator: (value) {
                                              if (selectedFromQuranStatus !=
                                                  null) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return context.loc
                                                      .validation_enter_ayah;
                                                }
                                                try {
                                                  final number =
                                                      int.parse(value);
                                                  if (number >
                                                          selectedFromQuranStatus!
                                                              .count ||
                                                      number < 1) {
                                                    return context.loc
                                                        .surah_exceed_ayahs(
                                                            selectedFromQuranStatus!
                                                                .count);
                                                  }
                                                } catch (e) {
                                                  return context.loc
                                                      .validation_enter_ayah;
                                                }
                                              } else if (selectedFromQuranStatus ==
                                                      null &&
                                                  (value != null &&
                                                      value.isNotEmpty)) {
                                                return context.loc
                                                    .validation_enter_ayah_after_surah;
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                        Expanded(
                                            child: TextFormField(
                                          autovalidateMode: AutovalidateMode
                                              .onUserInteraction,
                                          controller: _toAyahController,
                                          decoration: InputDecoration(
                                              suffix: selectedFromQuranStatus !=
                                                      null
                                                  ? IconButton(
                                                      onPressed: () {
                                                        _toAyahController.text =
                                                            selectedFromQuranStatus!
                                                                .count
                                                                .toString();
                                                      },
                                                      icon: const Icon(
                                                          Icons.arrow_upward))
                                                  : null,
                                              prefix: selectedFromQuranStatus !=
                                                      null
                                                  ? IconButton(
                                                      onPressed: () {
                                                        _toAyahController.text =
                                                            "1";
                                                      },
                                                      icon: const Icon(
                                                          Icons.arrow_downward))
                                                  : null,
                                              border:
                                                  const OutlineInputBorder(),
                                              labelText: context.loc.to_ayah,
                                              hintText: context.loc.to_ayah),
                                          keyboardType: TextInputType.number,
                                          inputFormatters: <TextInputFormatter>[
                                            FilteringTextInputFormatter
                                                .digitsOnly
                                          ],
                                          validator: (value) {
                                            if (selectedFromQuranStatus !=
                                                null) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return context
                                                    .loc.validation_enter_ayah;
                                              }
                                              try {
                                                final number = int.parse(value);
                                                if (number >
                                                        selectedFromQuranStatus!
                                                            .count ||
                                                    number < 1) {
                                                  return context.loc
                                                      .surah_exceed_ayahs(
                                                          selectedFromQuranStatus!
                                                              .count);
                                                }
                                              } catch (e) {
                                                return context
                                                    .loc.validation_enter_ayah;
                                              }
                                            } else if (selectedFromQuranStatus ==
                                                    null &&
                                                (value != null &&
                                                    value.isNotEmpty)) {
                                              return context.loc
                                                  .validation_enter_ayah_after_surah;
                                            }
                                            return null;
                                          },
                                        ))
                                      ],
                                    ),
                                  Row(
                                    children: [
                                      Text(context.loc.full_surah,
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineSmall),
                                      Checkbox.adaptive(
                                          value: _fullSurah,
                                          onChanged: (v) {
                                            if (v == null) return;
                                            setState(() {
                                              _fullSurah = v;
                                            });
                                          }),
                                    ],
                                  )
                                ],
                              );
                            }
                            return const CircularProgressIndicator();
                          }),
                    ],
                  ),
                ),
              ),
              // Align(
              //   alignment: Alignment.centerRight,
              //   child: Text(
              //     context.loc.to_surah,
              //     style: Theme.of(context).textTheme.headlineMedium!.copyWith(
              //         fontWeight: FontWeight.bold,
              //         color: Theme.of(context).colorScheme.onSurface),
              //   ),
              // ),
              // Card.filled(
              //   child: Container(
              //     padding: const EdgeInsets.all(8),
              //     child: Column(
              //       children: [
              //         FutureBuilder<List<QuranStatus>>(
              //             future: _futureQuranStatus,
              //             builder: (context, snapshot) {
              //               if (snapshot.hasData) {
              //                 return Column(
              //                   mainAxisSize: MainAxisSize.min,
              //                   children: [
              //                     DropdownSearch(
              //                       popupProps: const PopupProps.dialog(
              //                         showSearchBox: true,
              //                       ),
              //                       clearButtonProps: ClearButtonProps(
              //                         isVisible: selectedToQuranStatus != null,
              //                       ),
              //                       selectedItem: selectedToQuranStatus,
              //                       dropdownDecoratorProps:
              //                           DropDownDecoratorProps(
              //                         dropdownSearchDecoration: InputDecoration(
              //                           labelText: context.loc.surah,
              //                           border: const OutlineInputBorder(),
              //                         ),
              //                       ),
              //                       dropdownBuilder: (context, selectedItem) {
              //                         if (selectedItem == null) {
              //                           return Text(context.loc.surah,
              //                               style: const TextStyle(
              //                                   fontSize: 24,
              //                                   fontWeight: FontWeight.bold));
              //                         }
              //                         return Text(
              //                           selectedItem.titleAr,
              //                           style: const TextStyle(
              //                               fontSize: 24,
              //                               fontWeight: FontWeight.bold),
              //                         );
              //                       },
              //                       itemAsString: (item) => item.titleAr,
              //                       onChanged: (value) {
              //                         setState(() {
              //                           selectedToQuranStatus = value;
              //                         });
              //                       },
              //                       items: snapshot.data!,
              //                       validator: (value) => value == null
              //                           ? context.loc.validation_enter_surah
              //                           : null,
              //                     ),
              //                     const SizedBox(height: 8),

              //                   ],
              //                 );
              //               }
              //               return const CircularProgressIndicator();
              //             }),

              //         ),
              //       ],
              //     ),
              //   ),
              // ),
              Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    context.loc.revision_type,
                    style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface),
                  )),
              DropdownButtonFormField<ItemType>(
                  value: selectedQuranItemType,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    if (value == null) {
                      return context.loc.revision_type;
                    }
                    return null;
                  },
                  items: [
                    DropdownMenuItem(
                        value: ItemType.reading,
                        child: Text(context.loc.memorization)),
                    DropdownMenuItem(
                        value: ItemType.revision,
                        child: Text(context.loc.revision))
                  ],
                  onChanged: (v) {
                    setState(() => selectedQuranItemType = v);
                  }),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  context.loc.mark,
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface),
                ),
              ),
              TextFormField(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  controller: _noteController,
                  decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: context.loc.mark,
                      hintText: context.loc.mark),
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    // allow mark note with floating point
                    FilteringTextInputFormatter.allow(
                      RegExp(
                          r'^[0-9.,-]*$'), // Allow numbers, `,`, `.` and `-`.
                    ),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return context.loc.validation_mark_observation;
                    } else {
                      if (double.parse(value) > 20 || double.parse(value) < 1) {
                        return context.loc.mark;
                      }
                    }
                    return null;
                  }),
              if (widget.item == null)
                ElevatedButton(
                  onPressed: () {
                    if (_quranKey.currentState!.validate()) {
                      int fromayah;
                      int toayah;
                      if (!_fullSurah) {
                        fromayah = int.parse(_fromAyahController.text);

                        toayah = int.parse(_toAyahController.text);
                      } else {
                        fromayah = 1;
                        toayah = selectedFromQuranStatus!.count;
                      }
                      final note = double.parse(
                          _noteController.text.replaceAll(",", "."));

                      manageCubit.addQuran(
                        QuranItem(
                            type: selectedQuranItemType!,
                            fromQuranStatus: selectedFromQuranStatus!,
                            fromAyah: fromayah,
                            // toQuranStatus: selectedToQuranStatus!,
                            toAyah: toayah,
                            note: note),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(context.loc.has_been_added_successfully),
                      ));
                      Navigator.of(context).pop();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary),
                  child: Text(context.loc.add_surah),
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (_quranKey.currentState!.validate()) {
                            int fromayah;
                            int toayah;
                            if (!_fullSurah) {
                              fromayah = int.parse(_fromAyahController.text);

                              toayah = int.parse(_toAyahController.text);
                            } else {
                              fromayah = 1;
                              toayah = selectedFromQuranStatus!.count;
                            }
                            final note = double.parse(_noteController.text);

                            manageCubit
                                .updateQuranItem(
                              widget.item!,
                              QuranItem(
                                  type: selectedQuranItemType!,
                                  fromQuranStatus: selectedFromQuranStatus!,
                                  fromAyah: fromayah,
                                  // toQuranStatus: selectedToQuranStatus!,
                                  toAyah: toayah,
                                  note: note),
                            )
                                .then((_) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Text(
                                    context.loc.has_been_modified_successfully),
                              ));
                              Navigator.of(context).pop();
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary),
                        child: Text(context.loc.update_surah),
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.4,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_quranKey.currentState!.validate()) {
                            manageCubit.removeQuranItem(
                              widget.item!,
                            );
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(
                                  context.loc.has_been_deleted_successfully),
                            ));
                            Navigator.of(context).pop();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.errorContainer,
                            foregroundColor:
                                Theme.of(context).colorScheme.onErrorContainer),
                        child: Text(context.loc.remove),
                      ),
                    ),
                  ],
                )
            ],
          ),
        ),
      ),
    );
  }
}
