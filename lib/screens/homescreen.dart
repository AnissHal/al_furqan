import 'package:al_furqan/application/auth/auth_cubit.dart';
import 'package:al_furqan/application/profile/cubit/profile_cubit.dart';
import 'package:al_furqan/application/school/cubit/school_cubit.dart';
import 'package:al_furqan/application/services/asset_service.dart';
import 'package:al_furqan/application/theme/theme_cubit.dart';
import 'package:al_furqan/models/users.dart';
import 'package:al_furqan/screens/admin/dashboard.dart';
import 'package:al_furqan/screens/parent/dashboard.dart';
import 'package:al_furqan/screens/teacher/dashboard.dart';
import 'package:al_furqan/utils.dart';
import 'package:al_furqan/widgets/Profile_manage_header.dart';
import 'package:al_furqan/widgets/home_header.dart';
import 'package:al_furqan/widgets/password_dialog.dart';
import 'package:al_furqan/widgets/user_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Users? _userData;
  int _currentPage = 1;

  final ProfileCubit _profileCubit = ProfileCubit();

  @override
  void initState() {
    super.initState();
    final Users? userData =
        (context.read<AuthCubit>().state as UserAuthenticated).userData;
    _userData = userData;
  }

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(
      title: _userData != null
          ? BlocBuilder<SchoolCubit, SchoolState>(
              bloc: context.read<SchoolCubit>()
                ..loadSchool(_userData!.schoolId),
              builder: (context, state) {
                if (state is SchoolLoaded) {
                  return Text(
                    state.school.name,
                    style: Theme.of(context).textTheme.bodyLarge,
                  );
                }
                return Shimmer.fromColors(
                    baseColor: Colors.grey[200]!,
                    highlightColor: Colors.grey,
                    child: const TitlePlaceholder(
                      width: 150,
                    ));
              },
            )
          : Shimmer.fromColors(
              baseColor: Colors.grey[200]!,
              highlightColor: Colors.grey,
              child: const TitlePlaceholder(
                width: 150,
              )),
      elevation: 0,
      leading: _userData == null
          ? Container(
              decoration: const BoxDecoration(shape: BoxShape.circle),
              height: 50,
              width: 50,
              child: const Stack(
                fit: StackFit.expand,
                children: [
                  Icon(Icons.person),
                  Center(
                    child: CircularProgressIndicator(
                      color: Colors.teal,
                    ),
                  ),
                ],
              ))
          : Container(
              padding: const EdgeInsets.all(8),
              child: BlocBuilder<ProfileCubit, ProfileState>(
                bloc: _profileCubit,
                builder: (context, state) {
                  if (state is ProfileLoaded) {
                    final image = state.user.image;
                    return CircleAvatar(
                      foregroundImage: image != null && image.isNotEmpty
                          ? CachedNetworkImageProvider(
                              AssetService.composeImageURL(state.user))
                          : null,
                      backgroundColor:
                          image == null && image!.isEmpty ? Colors.teal : null,
                      child: Text(
                          state.user.fullName.characters.first.toUpperCase(),
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    );
                  }
                  return CircleAvatar(
                    foregroundImage:
                        _userData!.image != null && _userData!.image!.isNotEmpty
                            ? CachedNetworkImageProvider(
                                AssetService.composeImageURL(_userData!))
                            : null,
                    backgroundColor: Colors.teal,
                    child: Text(
                        _userData!.fullName.characters.first.toUpperCase(),
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  );
                },
              ),
            ),
    );
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is UserAuthenticated) {
          setState(() {
            _userData = state.userData;
          });
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: appBar,
        body: IndexedStack(
          index: _currentPage,
          children: [
            Column(
              children: [
                if (_userData == null) ...[
                  Expanded(
                    child: Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.grey.shade100,
                        child: HeaderPlaceholder(
                          width: MediaQuery.of(context).size.width,
                        )),
                  ),
                  Expanded(
                    flex: 1,
                    child: ListView(
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        ...List.generate(
                            5,
                            (e) => Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Shimmer.fromColors(
                                      baseColor: Colors.white24,
                                      highlightColor: Colors.grey,
                                      child: ListTilePlaceholder(
                                        height: 70,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                .9,
                                      )),
                                ))
                      ],
                    ),
                  )
                ] else ...[
                  Expanded(
                    child: ProfileHeader(
                      user: _userData!,
                      cubit: _profileCubit,
                    ),
                  ),
                  Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          ListTile(
                            onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (context) => const PasswordDialog());
                            },
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24)),
                            tileColor:
                                Theme.of(context).colorScheme.tertiaryContainer,
                            leading: const Icon(Icons.password_outlined),
                            title: Text(context.loc.password,
                                style: Theme.of(context).textTheme.bodyLarge),
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          ListTile(
                            onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (context) => UserDialog(
                                        user: _userData!,
                                      )).then((_) {
                                _profileCubit.loadProfile(_userData!);
                              });
                            },
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24)),
                            tileColor:
                                Theme.of(context).colorScheme.tertiaryContainer,
                            leading: const Icon(Icons.account_box),
                            title: Text(context.loc.update_user,
                                style: Theme.of(context).textTheme.bodyLarge),
                          ),
                          const Spacer(),
                          ListTile(
                            onTap: () {
                              context.read<AuthCubit>().logout().then((_) {
                                context.read<SchoolCubit>().resetState();
                              });
                            },
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24)),
                            tileColor: Theme.of(context)
                                .colorScheme
                                .secondaryContainer,
                            leading: const Icon(Icons.logout),
                            title: Text(context.loc.logout,
                                style: Theme.of(context).textTheme.bodyLarge),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                        ],
                      )),
                ]
              ],
            ),
            Column(
              children: [
                const Expanded(child: HomeHeaderWidget()),
                if (_userData == null) ...[
                  Expanded(
                    flex: 3,
                    child: GridView.count(
                      crossAxisCount: 3,
                      children: [
                        ...List.generate(
                            9,
                            (int index) => Shimmer.fromColors(
                                baseColor: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                                highlightColor: Theme.of(context)
                                    .colorScheme
                                    .secondaryContainer,
                                child: const CardPlaceholder(
                                  width: 150,
                                )))
                      ],
                    ),
                  )
                ] else ...[
                  switch (_userData!.role) {
                    UserRole.admin =>
                      const Expanded(flex: 3, child: AdminDashboardGrid()),
                    UserRole.parent =>
                      const Expanded(flex: 3, child: ParentDashboardGrid()),
                    UserRole.teacher =>
                      const Expanded(flex: 3, child: TeacherDashboardGrid()),
                    _ => const Expanded(flex: 3, child: AdminDashboardGrid()),
                  }
                ]
              ],
            ),
            Column(
              children: [
                if (_userData == null) ...[
                  Expanded(
                    flex: 3,
                    child: GridView.count(
                      crossAxisCount: 3,
                      children: [
                        ...List.generate(
                            9,
                            (int index) => Shimmer.fromColors(
                                baseColor: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                                highlightColor: Theme.of(context)
                                    .colorScheme
                                    .secondaryContainer,
                                child: const CardPlaceholder(
                                  width: 150,
                                )))
                      ],
                    ),
                  )
                ] else ...[
                  Expanded(
                    child: Column(children: [
                      Align(
                        alignment: Alignment.topCenter,
                        child: Text(context.loc.settings,
                            style: Theme.of(context).textTheme.headlineSmall),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      ListTile(
                        onTap: () {
                          context.read<ThemeCubit>().toggleTheme();
                        },
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24)),
                        leading: context.watch<ThemeCubit>().state is ThemeLight
                            ? const Icon(
                                Icons.dark_mode,
                                color: Colors.teal,
                              )
                            : const Icon(
                                Icons.light_mode,
                                color: Colors.amber,
                              ),
                        title: Text(
                            context.watch<ThemeCubit>().state is ThemeLight
                                ? context.loc.enable_dark_mode
                                : context.loc.enable_light_mode,
                            style: Theme.of(context).textTheme.bodyLarge),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      const Spacer(),
                      ListTile(
                        onTap: () {
                          launchUrl(Uri.parse("mailto:anisshal50@gmail.com"),
                              mode: LaunchMode.externalApplication);
                        },
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24)),
                        tileColor:
                            Theme.of(context).colorScheme.tertiaryContainer,
                        leading: const Icon(Icons.contact_support_outlined),
                        title: Text(context.loc.contact_developer,
                            style: Theme.of(context).textTheme.bodyLarge),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                    ]),
                  ),
                ]
              ],
            ),
          ],
        ),
        bottomNavigationBar: CurvedNavigationBar(
            height: 50,
            index: _currentPage,
            onTap: (i) {
              setState(() {
                _currentPage = i;
              });
            },
            animationDuration: const Duration(milliseconds: 250),
            color: Theme.of(context).colorScheme.primary,
            backgroundColor: Theme.of(context).colorScheme.surface,
            items: [
              if (_userData == null)
                const SizedBox(
                  height: 32,
                  width: 32,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Icon(
                        Icons.person,
                        color: Colors.white,
                      ),
                      CircularProgressIndicator(
                        color: Colors.white,
                      )
                    ],
                  ),
                )
              else
                const Icon(
                  Icons.person,
                  color: Colors.white,
                ),
              const Icon(
                Icons.home,
                color: Colors.white,
              ),
              const Icon(
                Icons.settings,
                color: Colors.white,
              )
            ]),
      ),
    );
  }
}

class TitlePlaceholder extends StatelessWidget {
  final double width;
  final double? height;

  const TitlePlaceholder({super.key, required this.width, this.height});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        width: width,
        height: height ?? 12.0,
        color: Colors.white60,
      ),
    );
  }
}

class CardPlaceholder extends StatelessWidget {
  final double width;

  const CardPlaceholder({
    super.key,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
      child: Container(
        width: width,
        height: 12.0,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(24),
        ),
      ),
    );
  }
}

class HeaderPlaceholder extends StatelessWidget {
  final double width;

  const HeaderPlaceholder({
    super.key,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SizedBox(
        width: width,
        child: Column(
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: const BoxDecoration(
                  color: Colors.grey, shape: BoxShape.circle),
            ),
            const SizedBox(
              height: 24,
            ),
            const TitlePlaceholder(
              width: 240,
            ),
            const SizedBox(
              height: 24,
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TitlePlaceholder(width: 120),
                TitlePlaceholder(width: 120),
              ],
            ),
            const SizedBox(
              height: 24,
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TitlePlaceholder(width: 120),
                TitlePlaceholder(width: 120),
              ],
            ),
            const SizedBox(
              height: 16,
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TitlePlaceholder(width: 120),
                TitlePlaceholder(width: 120),
              ],
            ),
            const SizedBox(
              height: 24,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: Container(
                    height: 60,
                    width: 60,
                    decoration: const BoxDecoration(
                        color: Colors.grey, shape: BoxShape.circle),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 60,
                    width: 60,
                    decoration: const BoxDecoration(
                        color: Colors.grey, shape: BoxShape.circle),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 60,
                    width: 60,
                    decoration: const BoxDecoration(
                        color: Colors.grey, shape: BoxShape.circle),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class ListTilePlaceholder extends StatelessWidget {
  final double width;
  final double? height;

  const ListTilePlaceholder({super.key, required this.width, this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height ?? 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Card(
        color: Theme.of(context).colorScheme.primaryContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        elevation: 2,
      ),
    );
  }
}
