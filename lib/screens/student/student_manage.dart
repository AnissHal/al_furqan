// import 'package:al_furqan/application/auth/auth_cubit.dart';
// import 'package:al_furqan/application/services/asset_service.dart';
// import 'package:al_furqan/application/student/crud/student_cubit.dart';
// import 'package:al_furqan/screens/student/student_manage_view.dart';
// import 'package:al_furqan/screens/teacher/register_screen.dart';
// import 'package:al_furqan/utils.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// class TeacherManageDashboard extends StatefulWidget {
//   const TeacherManageDashboard({super.key});

//   @override
//   State<TeacherManageDashboard> createState() => _TeacherManageDashboardState();
// }

// class _TeacherManageDashboardState extends State<TeacherManageDashboard> {
//   final _cubit = StudentCubit();

//   @override
//   void initState() {
//     super.initState();
//     final admin =
//         (context.read<AuthCubit>().state as UserAuthenticated).userData!;
//     _cubit.watchStudentsByTeacher(admin.id);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(context.loc.students_list),
//         automaticallyImplyLeading: true,
//       ),
//       body: BlocBuilder<StudentCubit, StudentState>(
//         bloc: _cubit,
//         builder: (context, state) {
//           return Column(
//             children: [
//               if (state is StudentLoaded)
//                 if (state.students.isEmpty)
//                   Expanded(
//                     child: Center(
//                       child: Text(
//                         "No Student yet",
//                         style: Theme.of(context).textTheme.headlineSmall,
//                       ),
//                     ),
//                   )
//                 else
//                   Expanded(
//                       child: ListView.builder(
//                           shrinkWrap: true,
//                           itemCount: state.students.length,
//                           itemBuilder: (context, index) {
//                             final student = state.students[index];
//                             return Card.outlined(
//                               shape: const RoundedRectangleBorder(
//                                   borderRadius:
//                                       BorderRadius.all(Radius.circular(8))),
//                               child: ListTile(
//                                 onTap: () {
//                                   Navigator.of(context).push(MaterialPageRoute(
//                                       builder: (context) => StudentManageView(
//                                             student: student,
//                                           )));
//                                 },
//                                 leading: student.image != null &&
//                                         student.image!.isNotEmpty
//                                     ? CircleAvatar(
//                                         foregroundImage:
//                                             CachedNetworkImageProvider(
//                                                 AssetService
//                                                     .composeStudentImageURL(
//                                                         student)),
//                                       )
//                                     : CircleAvatar(
//                                         child: Text(student
//                                             .fullName.characters.first
//                                             .toUpperCase()),
//                                       ),
//                                 subtitle: Row(
//                                   mainAxisSize: MainAxisSize.min,
//                                   children: [
//                                     Expanded(
//                                         child: ElevatedButton(
//                                       onPressed: () {
//                                         showDialog(
//                                             context: context,
//                                             builder: (context) {
//                                               return AlertDialog(
//                                                 title: Text(
//                                                     context.loc.delete_ayah),
//                                                 actions: [
//                                                   TextButton(
//                                                       onPressed: () =>
//                                                           Navigator.pop(
//                                                               context),
//                                                       child: Text(
//                                                           context.loc.cancel)),
//                                                   TextButton(
//                                                       onPressed: () {
//                                                         // TODO: DELETE STUDENT
//                                                         Navigator.of(context)
//                                                             .pop();
//                                                       },
//                                                       child: Text(
//                                                           context.loc.remove))
//                                                 ],
//                                               );
//                                             });
//                                       },
//                                       style: ElevatedButton.styleFrom(
//                                           backgroundColor: Theme.of(context)
//                                               .colorScheme
//                                               .error,
//                                           foregroundColor: Theme.of(context)
//                                               .colorScheme
//                                               .onError),
//                                       child: Text(context.loc.remove),
//                                     )),
//                                     const SizedBox(width: 8),
//                                     Expanded(
//                                         child: ElevatedButton(
//                                       onPressed: null,
//                                       child: Text(context.loc.update_ayah),
//                                     )),
//                                     const SizedBox(width: 8),
//                                     Expanded(
//                                         child: ElevatedButton(
//                                       onPressed: null,
//                                       child: Text(context.loc.remove),
//                                     )),
//                                   ],
//                                 ),
//                                 title: Text(student.fullName),
//                               ),
//                             );
//                           }))
//               else if (state is StudentError)
//                 Expanded(
//                   child: Center(
//                     child: Text(state.message),
//                   ),
//                 )
//               else
//                 const Expanded(
//                   child: Center(
//                     child: CircularProgressIndicator(),
//                   ),
//                 )
//             ],
//           );
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//           child: const Icon(Icons.add),
//           onPressed: () {
//             Navigator.of(context).push(MaterialPageRoute(
//                 builder: (context) => const RegisterScreen()));
//           }),
//     );
//   }
// }
