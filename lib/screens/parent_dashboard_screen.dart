// import 'package:al_furqan/application/auth/auth_cubit.dart';
// import 'package:al_furqan/application/student/crud/student_cubit.dart';
// import 'package:al_furqan/application/theme/theme_cubit.dart';
// import 'package:al_furqan/screens/student/student_view.dart';
// import 'package:al_furqan/utils.dart';
// import 'package:al_furqan/widgets/student_view_tile.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// class ParentDashboardScreen extends StatefulWidget {
//   const ParentDashboardScreen({super.key});

//   @override
//   State<ParentDashboardScreen> createState() => _ParentDashboardScreenState();
// }

// class _ParentDashboardScreenState extends State<ParentDashboardScreen> {
//   final _studentCubit = StudentCubit();

//   @override
//   void initState() {
//     super.initState();
//     _studentCubit.studentByParent(
//         (context.read<AuthCubit>().state as AuthParentAuthenticated).parent.id);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         centerTitle: true,
//         title: Text(context.loc.parent_dashboard),
//         leading: BlocBuilder<ThemeCubit, ThemeState>(
//           builder: (context, state) {
//             if (state is ThemeLight) {
//               return IconButton(
//                 icon: const Icon(Icons.dark_mode),
//                 onPressed: () {
//                   context.read<ThemeCubit>().toggleTheme();
//                 },
//               );
//             } else {
//               return IconButton(
//                 icon: const Icon(Icons.light_mode),
//                 onPressed: () {
//                   context.read<ThemeCubit>().toggleTheme();
//                 },
//               );
//             }
//           },
//         ),
//         actions: [
//           IconButton(
//               onPressed: () {
//                 context.read<AuthCubit>().logout();
//               },
//               icon: const Icon(Icons.logout))
//         ],
//       ),
//       body: RefreshIndicator(
//           onRefresh: () => _studentCubit.studentByParent(
//               (context.read<AuthCubit>().state as AuthParentAuthenticated)
//                   .parent
//                   .id),
//           child: Column(
//             children: [
//               Expanded(
//                 child: BlocConsumer<StudentCubit, StudentState>(
//                   bloc: _studentCubit,
//                   listener: (context, state) {
//                     if (state is StudentLoaded) {
//                       if (state.students.length == 1) {
//                         Navigator.of(context).push(MaterialPageRoute(
//                             builder: (context) => StudentView(
//                                   state.students[0],
//                                 )));
//                       }
//                     }
//                   },
//                   builder: (context, state) {
//                     switch (state) {
//                       case StudentLoaded():
//                         return ListView.builder(
//                           itemCount: state.students.length,
//                           shrinkWrap: true,
//                           itemBuilder: (context, index) {
//                             final student = state.students[index];
//                             return StudentViewTile(student);
//                           },
//                         );

//                       case StudentEmpty():
//                         return Center(
//                           child: Text(
//                             context.loc.no_students_found,
//                           ),
//                         );

//                       default:
//                         return const Center(child: CircularProgressIndicator());
//                     }
//                   },
//                 ),
//               ),
//             ],
//           )),
//     );
//   }
// }
