import 'package:al_furqan/application/services/json_service.dart';
import 'package:al_furqan/application/student/manage/student_manage_cubit.dart';
import 'package:al_furqan/models/mutn.dart';
import 'package:al_furqan/models/quran_status.dart';
import 'package:al_furqan/utils.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MutnDialog extends StatefulWidget {
  const MutnDialog({super.key, required this.cubit, this.item, this.index});

  final StudentManageCubit cubit;
  final MutnItem? item;
  final int? index;

  @override
  State<MutnDialog> createState() => _MutnDialogState();
}

class _MutnDialogState extends State<MutnDialog> {
  late Future<List<Mutn>> _futureMutn;
  final GlobalKey<FormState> _mutnKey = GlobalKey<FormState>();
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  Mutn? selectedFromMutn;
  // Mutn? selectedToMutn;

  bool _fullMutn = false;

  ItemType? selectedItemType;

  @override
  void initState() {
    super.initState();
    _futureMutn = JsonService.loadMutun();
    if (widget.item != null) {
      assert(widget.item != null && widget.index != null);
      final index = widget.index!;
      if (index != -1) {
        selectedFromMutn = widget.item!.fromMutn;
        // selectedToMutn = widget.item!.toMutn;
        selectedItemType = widget.item!.type;
        if (widget.item!.from == 1 &&
            widget.item!.to == selectedFromMutn!.count) {
          _fullMutn = true;
        }
        _fromController.text = widget.item!.from.toString();
        _toController.text = widget.item!.to.toString();
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
          key: _mutnKey,
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  context.loc.mutn,
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
                      FutureBuilder<List<Mutn>>(
                          future: _futureMutn,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return Column(
                                children: [
                                  DropdownSearch(
                                    popupProps: const PopupProps.dialog(
                                      showSearchBox: true,
                                    ),
                                    clearButtonProps: ClearButtonProps(
                                      isVisible: selectedFromMutn != null,
                                    ),
                                    selectedItem: selectedFromMutn,
                                    dropdownDecoratorProps:
                                        DropDownDecoratorProps(
                                      dropdownSearchDecoration: InputDecoration(
                                        labelText: context.loc.mutn,
                                        border: const OutlineInputBorder(),
                                      ),
                                    ),
                                    dropdownBuilder: (context, selectedItem) {
                                      if (selectedItem == null) {
                                        return Text(context.loc.mutn,
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
                                        selectedFromMutn = value;
                                      });
                                    },
                                    items: snapshot.data!,
                                    validator: (value) => value == null
                                        ? context.loc.validation_select_mutn
                                        : null,
                                  ),
                                  const SizedBox(height: 8),
                                  if (!_fullMutn)
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextFormField(
                                            autovalidateMode: AutovalidateMode
                                                .onUserInteraction,
                                            controller: _fromController,
                                            decoration: InputDecoration(
                                                suffix: selectedFromMutn != null
                                                    ? IconButton(
                                                        onPressed: () {
                                                          _fromController.text =
                                                              selectedFromMutn!
                                                                  .count
                                                                  .toString();
                                                        },
                                                        icon: const Icon(
                                                            Icons.arrow_upward))
                                                    : null,
                                                prefix: selectedFromMutn != null
                                                    ? IconButton(
                                                        onPressed: () {
                                                          _fromController.text =
                                                              "1";
                                                        },
                                                        icon: const Icon(Icons
                                                            .arrow_downward))
                                                    : null,
                                                border:
                                                    const OutlineInputBorder(),
                                                labelText: context.loc.from,
                                                hintText: context.loc.from),
                                            keyboardType: TextInputType.number,
                                            inputFormatters: <TextInputFormatter>[
                                              FilteringTextInputFormatter
                                                  .digitsOnly
                                            ],
                                            validator: (value) {
                                              if (selectedFromMutn != null) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return context.loc
                                                      .validation_select_from_page;
                                                }
                                                try {
                                                  final number =
                                                      int.parse(value);
                                                  if (number >
                                                          selectedFromMutn!
                                                              .count ||
                                                      number < 1) {
                                                    return context.loc
                                                        .mutn_exceed_pages(
                                                            selectedFromMutn!
                                                                .count);
                                                  }
                                                } catch (e) {
                                                  return context.loc
                                                      .validation_enter_valid_number;
                                                }
                                              } else if (selectedFromMutn ==
                                                      null &&
                                                  (value != null &&
                                                      value.isNotEmpty)) {
                                                return context.loc
                                                    .validation_select_from_page;
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                        Expanded(
                                            child: TextFormField(
                                          autovalidateMode: AutovalidateMode
                                              .onUserInteraction,
                                          controller: _toController,
                                          decoration: InputDecoration(
                                              prefix: selectedFromMutn != null
                                                  ? IconButton(
                                                      onPressed: () {
                                                        _toController.text =
                                                            "1";
                                                      },
                                                      icon: const Icon(
                                                          Icons.arrow_downward))
                                                  : null,
                                              suffix: selectedFromMutn != null
                                                  ? IconButton(
                                                      onPressed: () {
                                                        _toController.text =
                                                            (selectedFromMutn!
                                                                    .count)
                                                                .toString();
                                                      },
                                                      icon: const Icon(
                                                          Icons.arrow_upward))
                                                  : null,
                                              border:
                                                  const OutlineInputBorder(),
                                              labelText: context.loc.to,
                                              hintText: context.loc.to),
                                          keyboardType: TextInputType.number,
                                          inputFormatters: <TextInputFormatter>[
                                            FilteringTextInputFormatter
                                                .digitsOnly
                                          ],
                                          validator: (value) {
                                            if (selectedFromMutn != null) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return context.loc
                                                    .validation_select_from_page;
                                              }
                                              try {
                                                final number = int.parse(value);
                                                if (number >
                                                        selectedFromMutn!
                                                            .count ||
                                                    number < 1) {
                                                  return context.loc
                                                      .mutn_exceed_pages(
                                                          selectedFromMutn!
                                                              .count);
                                                }
                                              } catch (e) {
                                                return context.loc
                                                    .validation_enter_valid_number;
                                              }
                                            } else if (selectedFromMutn ==
                                                    null &&
                                                (value != null &&
                                                    value.isNotEmpty)) {
                                              return context.loc
                                                  .validation_select_to_page;
                                            }
                                            return null;
                                          },
                                        ))
                                      ],
                                    ),
                                  Row(
                                    children: [
                                      Text(context.loc.full_mutn,
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineSmall),
                                      Checkbox.adaptive(
                                          value: _fullMutn,
                                          onChanged: (v) {
                                            if (v == null) return;
                                            setState(() {
                                              _fullMutn = v;
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
              //     context.loc.to_mutn,
              //     style: Theme.of(context).textTheme.headlineMedium!.copyWith(
              //         fontWeight: FontWeight.bold,
              //         color: Theme.of(context).colorScheme.onSurface),
              //   ),
              // ),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  context.loc.revision_type,
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface),
                ),
              ),
              DropdownButtonFormField<ItemType>(
                  value: selectedItemType,
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
                        child: Text(context.loc.revision)),
                  ],
                  onChanged: (v) {
                    setState(() => selectedItemType = v);
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
                    // allow mark note with floating point max 20/20
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
              const SizedBox(height: 20),
              if (widget.item == null)
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_mutnKey.currentState!.validate()) {
                        int from, to;
                        if (!_fullMutn) {
                          from = int.parse(_fromController.text);

                          to = int.parse(_toController.text);
                        } else {
                          from = 1;
                          to = selectedFromMutn!.count;
                        }

                        final note = double.parse(
                            _noteController.text.replaceAll(",", "."));

                        manageCubit
                            .addMutn(
                          MutnItem(
                              type: selectedItemType!,
                              fromMutn: selectedFromMutn!,
                              from: from,
                              to: to,
                              note: note),
                        )
                            .then((_) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content:
                                Text(context.loc.has_been_added_successfully),
                          ));
                          Navigator.of(context).pop();
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary),
                    child: Text(context.loc.add_mutn),
                  ),
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (_mutnKey.currentState!.validate()) {
                            int from, to;
                            if (!_fullMutn) {
                              from = int.parse(_fromController.text);

                              to = int.parse(_toController.text);
                            } else {
                              from = 1;
                              to = selectedFromMutn!.count;
                            }
                            final note = double.parse(_noteController.text);

                            manageCubit
                                .updateMutnItem(
                              widget.item!,
                              MutnItem(
                                  type: selectedItemType!,
                                  fromMutn: selectedFromMutn!,
                                  from: from,
                                  // toMutn: selectedToMutn!,
                                  to: to,
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
                        child: Text(context.loc.update_mutn),
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.4,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_mutnKey.currentState!.validate()) {
                            manageCubit
                                .removeMutnItem(
                              widget.item!,
                            )
                                .then((_) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Text(
                                    context.loc.has_been_deleted_successfully),
                              ));
                              Navigator.of(context).pop();
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.errorContainer,
                            foregroundColor:
                                Theme.of(context).colorScheme.onErrorContainer),
                        child: Text(context.loc.delete_mutn),
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
