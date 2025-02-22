import 'package:al_furqan/models/quran_status.dart';
import 'package:al_furqan/utils.dart';
import 'package:flutter/material.dart';

class QuranViewPage extends StatelessWidget {
  const QuranViewPage({super.key, required this.items});
  final List<QuranItem> items;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.loc.quran),
      ),
      body: SafeArea(
          child: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final quran = items[index];
          final isfull = quran.fromAyah == 1 &&
              quran.toAyah == quran.fromQuranStatus.count;
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
                            color: quran.type == ItemType.revision
                                ? Colors.teal
                                : Colors.green,
                            borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(24),
                                bottomRight: Radius.circular(24)),
                          ),
                          child: Center(
                            child: Text(
                              quran.type == ItemType.revision
                                  ? isfull
                                      ? context.loc.full_surah_revision
                                      : context.loc.revision
                                  : isfull
                                      ? context.loc.full_surah_memorization
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
                          "${context.loc.surah} ${quran.fromQuranStatus.titleAr}",
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
                                    "${context.loc.from_ayah} ${quran.fromAyah.toString()}",
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
                                    "${context.loc.to_ayah} ${quran.toAyah.toString()}",
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
                          "${context.loc.mark} ${quran.note.toString()}/20",
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
