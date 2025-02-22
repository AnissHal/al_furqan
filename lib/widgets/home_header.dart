import 'package:al_furqan/application/auth/auth_cubit.dart';
import 'package:al_furqan/application/school/cubit/school_cubit.dart';
import 'package:al_furqan/application/services/asset_service.dart';
import 'package:al_furqan/models/users.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';

class HomeHeaderWidget extends StatefulWidget {
  const HomeHeaderWidget({super.key});

  @override
  State<HomeHeaderWidget> createState() => _HomeHeaderWidgetState();
}

class _HomeHeaderWidgetState extends State<HomeHeaderWidget> {
  late Users? _userData;

  @override
  void initState() {
    super.initState();
    HijriCalendar.setLocal('ar');
    final Users? userData =
        (context.read<AuthCubit>().state as UserAuthenticated).userData;
    _userData = userData;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is UserAuthenticated) {
          setState(() {
            _userData = state.userData;
          });
        }
      },
      child: Container(
        color: Theme.of(context).colorScheme.primary,
        child: Stack(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  DateFormat('dd MMMM yyyy', 'ar-DZ').format(DateTime.now()),
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge!
                      .copyWith(color: Colors.white),
                ),
                Text(
                  HijriCalendar.now().fullDate(),
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge!
                      .copyWith(color: Colors.white),
                ),
              ],
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24))),
              ),
            ),
            if (_userData != null)
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * .3,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(),
                      image: DecorationImage(
                          scale: 2,
                          fit: BoxFit.fill,
                          image: CachedNetworkImageProvider(
                              AssetService.fetchSchoolImageFromNetwork((context
                                      .watch<SchoolCubit>()
                                      .state as SchoolLoaded)
                                  .school),
                              cacheKey: 'logo'))),
                ),
              ),
            const SizedBox.expand(),
          ],
        ),
      ),
    );
  }
}
