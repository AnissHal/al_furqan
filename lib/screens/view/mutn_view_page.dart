import 'package:al_furqan/models/mutn.dart';
import 'package:al_furqan/models/quran_status.dart';
import 'package:al_furqan/utils.dart';
import 'package:flutter/material.dart';

class MutnViewPage extends StatelessWidget {
  const MutnViewPage({super.key, required this.items});
  final List<MutnItem> items;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.loc.mutn),
      ),
      body: SafeArea(
          child: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final mutn = items[index];
          final isfull = mutn.from == 1 && mutn.to == mutn.fromMutn.count;
          return SizedBox(
            width: MediaQuery.of(context).size.width * .95,
            child: Column(
              children: [
                Card.outlined(
                    color: Theme.of(context).colorScheme.inverseSurface,
                    child: Column(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            color: mutn.type == ItemType.revision
                                ? Colors.teal
                                : Colors.green,
                            borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(24),
                                bottomRight: Radius.circular(24)),
                          ),
                          child: Center(
                            child: Text(
                              mutn.type == ItemType.revision
                                  ? isfull
                                      ? context.loc.full_mutn_revision
                                      : context.loc.revision
                                  : isfull
                                      ? context.loc.full_mutn_memorization
                                      : context.loc.memorization,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall!
                                  .copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black),
                            ),
                          ),
                        ),
                        Text(
                          mutn.fromMutn.titleAr,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall!
                              .copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onInverseSurface,
                                  fontWeight: FontWeight.bold),
                        ),
                        if (!isfull)
                          Row(
                            children: [
                              Expanded(
                                child: Column(children: [
                                  Text(
                                    "${context.loc.from_page} ${mutn.from.toString()}",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .copyWith(
                                            color: Theme.of(context)
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
                                    "${context.loc.to_page} ${mutn.to.toString()}",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .copyWith(
                                            color: Theme.of(context)
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
                          "${context.loc.mark} ${mutn.note.toString()}/20",
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onInverseSurface),
                        )
                      ],
                    )),
              ],
            ),
          );
        },
      )),
    );
  }
}
