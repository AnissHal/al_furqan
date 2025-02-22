import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:al_furqan/models/student.dart';
import 'package:al_furqan/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

class BadgePainter extends CustomPainter {
  final ui.Image baseImage;
  final ui.Image? avatar;
  final String qrData;
  final Student student;

  BadgePainter({
    required this.baseImage,
    required this.qrData,
    required this.avatar,
    required this.student,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw the base image
    canvas.drawImage(baseImage, Offset.zero, Paint());
    if (avatar != null) {
      paintImage(
          canvas: canvas,
          rect: const Rect.fromLTWH(185, 200, 220, 220),
          image: avatar!);
    }
    // white background
    // canvas.drawRect(Rect.fromLTRB(0, 0, size.width, size.height),
    //     Paint()..color = Colors.white);

    // Draw the QR code
    final qrPainter = QrPainter(
      data: qrData,
      version: QrVersions.auto,
    );
    const qrSize = 190.0; // Size of the QR code
    const qrOffset = Offset(200, 730); // Position inside the "Scan me" box

    canvas.save();
    canvas.translate(qrOffset.dx, qrOffset.dy);
    qrPainter.paint(canvas, const Size(qrSize, qrSize));
    canvas.restore();

    // Draw the student name
    const textStyle = TextStyle(
        color: Colors.black,
        fontSize: 54,
        fontWeight: FontWeight.bold,
        overflow: TextOverflow.clip);
    final textSpan = TextSpan(
      text: student.fullName,
      style: textStyle,
    );
    final textPainter = TextPainter(
      text: textSpan,
      textAlign: TextAlign.start,
      maxLines: 1,
      textDirection: TextDirection.rtl,
    );

    // Define the max width for wrapping
    final double maxTextWidth =
        size.width - 20; // Adjust padding from the right
    textPainter.layout(maxWidth: maxTextWidth);
    final textSize = textPainter.size;

    final diff = (size.width - textSize.width);
    final nameOffset =
        Offset(diff - (diff / 2), 575); // Position for the student name
    textPainter.paint(canvas, nameOffset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class BadgeScreen extends StatefulWidget {
  final Student student;
  final String? avatar;
  const BadgeScreen({super.key, required this.student, required this.avatar});

  @override
  State<BadgeScreen> createState() => _BadgeScreenState();
}

class _BadgeScreenState extends State<BadgeScreen> {
  ui.Image? _baseImage;
  ui.Image? _avatarImage;
  final GlobalKey _repaintKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _loadBaseImage();
  }

  Future<void> _loadBaseImage() async {
    final ByteData data = await rootBundle
        .load('assets/badge.jpg'); // Replace with your image path

    if (widget.avatar != null) {
      final Uint8List avatarBytes = await http
          .get(Uri.parse(widget.avatar!))
          .then((res) => res.bodyBytes);
      final ui.Codec avatarCodec = await ui.instantiateImageCodec(avatarBytes);
      final ui.FrameInfo avatarFrame = await avatarCodec.getNextFrame();
      setState(() {
        _avatarImage = avatarFrame.image;
      });
    }

    final Uint8List bytes = data.buffer.asUint8List();
    final ui.Codec codec = await ui.instantiateImageCodec(bytes);
    final ui.FrameInfo frame = await codec.getNextFrame();
    setState(() {
      _baseImage = frame.image;
    });
  }

  Future<void> _saveBadgeAsPng() async {
    try {
      // Capture the image from RepaintBoundary
      RenderRepaintBoundary boundary = _repaintKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(
          pixelRatio: 3.0); // Adjust pixel ratio for higher resolution
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      // Save to a file
      final directory = await getApplicationDocumentsDirectory();

      final filePath =
          '${directory.path}/${widget.student.fullName}_${widget.student.id}.png';
      final file = File(filePath);
      await file.writeAsBytes(pngBytes);
      await GallerySaver.saveImage(filePath);
      // remove file after saving to gallery
      await file.delete();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving badge: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_baseImage == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(context.loc.badge),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveBadgeAsPng,
          ),
        ],
      ),
      body: Center(
        child: FittedBox(
          fit: BoxFit.contain,
          child: RepaintBoundary(
            key: _repaintKey,
            child: CustomPaint(
              size: Size(
                  _baseImage!.width.toDouble(), _baseImage!.height.toDouble()),
              painter: BadgePainter(
                baseImage: _baseImage!,
                avatar: _avatarImage,
                qrData: jsonEncode(
                    {'id': widget.student.id}), // Replace with dynamic QR data
                student: widget.student, // Replace with dynamic student name
              ),
            ),
          ),
        ),
      ),
    );
  }
}
