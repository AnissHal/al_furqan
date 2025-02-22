import 'package:al_furqan/utils.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LoadingWidget extends StatelessWidget {
  LoadingWidget({super.key});
  final random = [1, 2].elementAt(DateTime.now().second % 2);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            context.loc.app_title,
            style: Theme.of(context)
                .textTheme
                .headlineLarge!
                .copyWith(fontWeight: FontWeight.bold),
          ),
          AspectRatio(
              aspectRatio: 1.2,
              child: Lottie.asset('assets/lottie/man_quran$random.json')),
          const SizedBox(
              width: 50, height: 50, child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
