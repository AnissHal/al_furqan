import 'package:al_furqan/application/auth/auth_cubit.dart';
import 'package:al_furqan/application/services/asset_service.dart';
import 'package:al_furqan/models/file.dart';
import 'package:al_furqan/models/users.dart';
import 'package:al_furqan/screens/file/file_dialog.dart';
import 'package:al_furqan/screens/file/file_viewer.dart';
import 'package:al_furqan/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FileScreen extends StatefulWidget {
  const FileScreen({super.key});

  @override
  State<FileScreen> createState() => _FileScreenState();
}

class _FileScreenState extends State<FileScreen> {
  late Future _fileFuture;
  late Users _user;
  @override
  void initState() {
    _user = (context.read<AuthCubit>().state as UserAuthenticated).userData!;
    _fileFuture = AssetService.fetchFiles(_user.schoolId);
    super.initState();
  }

  final appBar = (BuildContext context) => AppBar(
        centerTitle: true,
        title: Text(context.loc.files),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _fileFuture = AssetService.fetchFiles(_user.schoolId);
          });
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height -
                appBar(context).preferredSize.height -
                MediaQuery.of(context).viewPadding.top,
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [
                Expanded(
                  child: FutureBuilder(
                      future: _fileFuture,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          if (snapshot.data!.isEmpty) {
                            Center(
                              child: Text(
                                context.loc.no_file_yet,
                                style:
                                    Theme.of(context).textTheme.headlineMedium,
                              ),
                            );
                          }

                          return ListView.builder(
                              itemCount: snapshot.data!.length,
                              itemBuilder: (context, index) {
                                final file =
                                    snapshot.data![index] as StorageFile;
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ListTile(
                                    onLongPress: () {
                                      if (_user.role == UserRole.admin) {
                                        showDialog<bool?>(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                                    title: Text(
                                                        context.loc.remove),
                                                    content: Text(context
                                                        .loc.delete_file),
                                                    actions: [
                                                      TextButton(
                                                          onPressed: () {
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          child: Text(
                                                              context.loc.no)),
                                                      TextButton(
                                                          onPressed: () {
                                                            AssetService.deleteFile(
                                                                    schoolId: _user
                                                                        .schoolId,
                                                                    name: file
                                                                        .name)
                                                                .then((_) {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop(true);
                                                            });
                                                          },
                                                          child: Text(
                                                              context.loc.yes))
                                                    ])).then((b) {
                                          if (b == true) {
                                            setState(() {
                                              _fileFuture =
                                                  AssetService.fetchFiles(
                                                      _user.schoolId);
                                            });
                                          }
                                        });
                                      }
                                    },
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(24)),
                                    onTap: () {
                                      Navigator.of(context)
                                          .push(MaterialPageRoute(
                                              builder: (context) => FileViewer(
                                                    schoolId: _user.schoolId,
                                                    file: file,
                                                  )));
                                    },
                                    leading: switch (
                                        file.name.split('.').last.toString()) {
                                      'jpg' => const Icon(Icons.image),
                                      'png' => const Icon(Icons.image),
                                      'jpeg' => const Icon(Icons.image),
                                      'pdf' => const Icon(
                                          Icons.picture_as_pdf,
                                        ),
                                      'doc' => const Icon(
                                          Icons.picture_as_pdf,
                                        ),
                                      'docx' => const Icon(
                                          Icons.picture_as_pdf,
                                        ),
                                      _ => const Icon(
                                          Icons.file_upload_sharp,
                                        ),
                                    },
                                    tileColor: Theme.of(context)
                                        .colorScheme
                                        .secondaryContainer,
                                    trailing: const Icon(Icons.visibility),
                                    title: Text(
                                      file.name.toString(),
                                      style:
                                          Theme.of(context).textTheme.bodyLarge,
                                    ),
                                  ),
                                );
                              });
                        }
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (snapshot.hasError) {
                          return Center(
                            child: Text(snapshot.error.toString()),
                          );
                        }
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }),
                )
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: _user.role == UserRole.admin
          ? FloatingActionButton(
              onPressed: () {
                showDialog<bool>(
                    context: context,
                    builder: (context) {
                      return FileDialog(user: _user);
                    }).then((b) {
                  if (b == true) {
                    setState(() {
                      _fileFuture = AssetService.fetchFiles(_user.schoolId);
                    });
                  }
                });
              },
              child: const Icon(Icons.add))
          : null,
    );
  }
}
