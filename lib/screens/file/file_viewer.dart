import 'dart:typed_data';

import 'package:al_furqan/application/services/asset_service.dart';
import 'package:al_furqan/models/file.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:photo_view/photo_view.dart';

class FileViewer extends StatefulWidget {
  const FileViewer({super.key, required this.file, required this.schoolId});

  final StorageFile file;
  final String schoolId;

  @override
  State<FileViewer> createState() => _FileViewerState();
}

class _FileViewerState extends State<FileViewer> {
  Uint8List? data;

  @override
  void initState() {
    AssetService.downloadFile(widget.file.name, widget.schoolId).then((d) {
      setState(() {
        data = d;
      });
    });
    super.initState();
  }

  Widget handleData(Uint8List data) {
    final ext = widget.file.name.split('.').last;
    final imageExt = ['png', 'jpg', 'jpeg'];
    if (imageExt.contains(ext)) {
      return Expanded(
        child: PhotoView(
            imageProvider: Image.memory(
          data,
        ).image),
      );
    }
    if (ext == 'pdf') {
      return Expanded(
        child: PDFView(
          pdfData: data,
        ),
      );
    }

    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (data != null) ...[
              Text(
                widget.file.name,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              handleData(data!)
            ] else
              const Center(
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }
}
