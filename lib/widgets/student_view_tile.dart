import 'package:al_furqan/application/services/asset_service.dart';
import 'package:al_furqan/application/services/student_service.dart';
import 'package:al_furqan/screens/student/student_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/student.dart';

class StudentViewTile extends StatelessWidget {
  final Student student;

  const StudentViewTile(this.student, {super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => StudentView(
                  student,
                )));
      },
      child: Card.outlined(
        child: Dismissible(
          key: Key(student.id),
          onDismissed: (direction) {},
          background: Container(
            color: Colors.red,
            child: Row(
              children: [
                IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.delete, color: Colors.white)),
                const Spacer(),
                IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.delete, color: Colors.white)),
              ],
            ),
          ),
          confirmDismiss: (direction) async =>
              await StudentService.find(student.id) == null,
          child: ListTile(
            leading: CircleAvatar(
              foregroundImage: student.image == null
                  ? null
                  : CachedNetworkImageProvider(
                      AssetService.composeStudentImageURL(student),
                      cacheKey: student.image),
              child: student.image == null
                  ? Text(student.fullName[0].toUpperCase())
                  : null,
            ),
            title: Text(student.fullName),
          ),
        ),
      ),
    );
  }
}
