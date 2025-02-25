import 'package:al_furqan/application/services/asset_service.dart';
import 'package:al_furqan/models/users.dart';
import 'package:al_furqan/utils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class FileDialog extends StatefulWidget {
  const FileDialog({super.key, required this.user});
  final Users user;

  @override
  State<FileDialog> createState() => _FileDialogState();
}

class _FileDialogState extends State<FileDialog> {
  final GlobalKey<FormFieldState> nameKey = GlobalKey();
  final TextEditingController _controller = TextEditingController();
  PlatformFile? file;
  bool _uploading = false;

  void _handleFileUpload(FilePickerResult? file) {
    if (file != null) {
      setState(() {
        this.file = file.files.first;
      });

      _controller.text = file.files.first.name.split('.').first;

      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: Column(
        children: [
          Text(
            context.loc.upload_file,
            style: Theme.of(context)
                .textTheme
                .headlineSmall!
                .copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 16,
          ),
          InkWell(
            onTap: () {
              FilePicker.platform
                  .pickFiles(
                    type: FileType.custom,
                    allowMultiple: false,
                    allowedExtensions: [
                      'jpeg',
                      'jpg',
                      'png',
                      'pdf',
                      'doc',
                      'docx'
                    ],
                  )
                  .then((value) => _handleFileUpload(value))
                  .catchError((e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(context.loc.unknown_error)));
                  });
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(30)),
                color: Theme.of(context).colorScheme.secondaryContainer,
              ),
              width: MediaQuery.of(context).size.width * .8,
              child: AspectRatio(
                aspectRatio: 1.2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),
                    if (file == null) ...[
                      const Center(
                        child: Icon(
                          Icons.file_upload_sharp,
                          size: 72,
                        ),
                      ),
                      const Spacer()
                    ] else
                      switch (file!.extension.toString()) {
                        'jpg' => const Icon(Icons.image, size: 72),
                        'png' => const Icon(Icons.image, size: 72),
                        'jpeg' => const Icon(Icons.image, size: 72),
                        'pdf' => const Icon(Icons.picture_as_pdf, size: 72),
                        'doc' => const Icon(Icons.picture_as_pdf, size: 72),
                        'docx' => const Icon(Icons.picture_as_pdf, size: 72),
                        _ => const Icon(Icons.file_upload_sharp, size: 72),
                      },
                    if (file != null) ...[
                      Text(
                        file!.extension.toString().toUpperCase(),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const Spacer(),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * .7,
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .errorContainer,
                                foregroundColor: Theme.of(context)
                                    .colorScheme
                                    .onErrorContainer),
                            onPressed: () {
                              setState(() {
                                _controller.text = '';
                                file = null;
                              });
                            },
                            child: Text(context.loc.remove)),
                      )
                    ]
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.tertiaryContainer, // Li
                borderRadius: const BorderRadius.all(Radius.circular(24))),
            child: TextFormField(
              key: nameKey,
              controller: _controller,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return context.loc.verify_file_name;
                }
                return null;
              },
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: InputBorder.none,
                icon: const Icon(Icons.file_copy),
                labelText: context.loc.file_name,
              ),
            ),
          ),
          const SizedBox(height: 8),
          if (_uploading)
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * .5,
                    decoration: const BoxDecoration(shape: BoxShape.circle),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Stack(fit: StackFit.expand, children: [
                        const CircularProgressIndicator(),
                        Center(
                            child: Text(context.loc.wait_while_uploading,
                                style: Theme.of(context).textTheme.bodyLarge!))
                      ]),
                    ),
                  ),
                ],
              ),
            )
          else ...[
            Expanded(
              child: Center(
                child: ClipOval(
                  child: InkWell(
                    onTap: () {
                      if (file == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(context.loc.file)));
                        return;
                      }
                      if (_controller.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(context.loc.verify_file_name)));
                        return;
                      }
                      setState(() {
                        _uploading = true;
                      });

                      AssetService.uploadFile(
                              file!, _controller.text, widget.user)
                          .then((_) {
                        setState(() {
                          _uploading = false;
                        });
                        Navigator.of(context).pop(true);
                      }).catchError((e) {});
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width * .5,
                      decoration: const BoxDecoration(shape: BoxShape.circle),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Stack(fit: StackFit.expand, children: [
                          const CircularProgressIndicator(
                            value: 1,
                          ),
                          Center(
                            child: Text(
                              context.loc.upload_file,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface),
                            ),
                          )
                        ]),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ]
        ],
      ),
    );
  }
}
