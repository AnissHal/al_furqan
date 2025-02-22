import 'dart:async';
import 'dart:convert';

import 'package:al_furqan/application/auth/auth_cubit.dart';
import 'package:al_furqan/application/services/attendance_service.dart';
import 'package:al_furqan/application/services/student_service.dart';
import 'package:al_furqan/models/attendance.dart';
import 'package:al_furqan/models/student.dart';
import 'package:al_furqan/utils.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  bool _blockScan = false;
  bool _showLottie = true;
  Timer? _blockScanTimer;
  Timer? _lottieTimer;
  Student? _student;
  final AudioPlayer _audioPlayer = AudioPlayer();

  final MobileScannerController _controller = MobileScannerController(
    facing: CameraFacing.back,
  );

  @override
  void initState() {
    super.initState();
    _lottieTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        setState(() {
          _showLottie = false;
          _lottieTimer?.cancel();
        });
      });
    });

    // _audioPlayer.setSourceAsset('done.mp3');
    // _audioPlayer.setPlayerMode(PlayerMode.lowLatency);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MobileScanner(
        overlayBuilder: (context, constraints) {
          return SizedBox(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              child: Stack(
                children: [
                  Column(
                    children: [
                      Container(
                        width: constraints.maxWidth,
                        height: constraints.maxHeight * .15,
                        color: Colors.black.withOpacity(.6),
                      ),
                      SizedBox(
                          height: constraints.maxHeight * .7,
                          width: 250,
                          child: Center(
                            child: _blockScan && _student == null
                                ? const CircularProgressIndicator()
                                : _showLottie
                                    ? Center(
                                        child: Lottie.asset(
                                            'assets/lottie/scan_qr.json'))
                                    : null,
                          )),
                      Container(
                        width: constraints.maxWidth,
                        height: constraints.maxHeight * .15,
                        color: Colors.black.withOpacity(.6),
                      ),
                    ],
                  ),
                  if ((_student != null))
                    Center(
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Container(
                            decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                                borderRadius: BorderRadius.circular(12)),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _student!.fullName,
                                  style: Theme.of(context)
                                      .textTheme
                                      .displaySmall!
                                      .copyWith(color: Colors.black),
                                ),
                                SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * .5,
                                    child: QrImageView(
                                        data: {'id': _student!.id}.toString())),
                                Text(context.loc.present,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineLarge)
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                ],
              ));
        },
        controller: _controller,
        onDetect: (barcodes) async {
          if (_blockScan) return;
          if (barcodes.barcodes.isNotEmpty) {
            final code = barcodes.barcodes.first.rawValue;
            if (code != null) {
              // try parse the code as json and skip if not valid json {'id': '123'}
              try {
                final json = jsonDecode(code);
                if (json['id'] != null) {
                  // post callback
                  final student = await StudentService.find(json['id']);
                  if (student == null) return;
                  WidgetsBinding.instance.addPostFrameCallback((d) {
                    setState(() {
                      _blockScan = true;
                      _student = student;
                      final date = DateTime.now();
                      final teacherId =
                          (context.read<AuthCubit>().state as UserAuthenticated)
                              .supabaseUser
                              .id;
                      AttendanceService.addAttendance(_student!.id, teacherId,
                          date, AttendanceStatus.present);
                      _audioPlayer.play(AssetSource('done.mp3'), volume: 1);
                      _blockScanTimer?.cancel();
                      _blockScanTimer = Timer(const Duration(seconds: 3), () {
                        WidgetsBinding.instance.addPostFrameCallback((d) {
                          setState(() {
                            _blockScan = false;
                            _showLottie = true;
                            _student = null;
                          });
                          _lottieTimer = Timer(const Duration(seconds: 3), () {
                            WidgetsBinding.instance.addPostFrameCallback((d) {
                              setState(() {
                                _showLottie = false;
                              });
                            });
                          });
                        });
                      });
                    });
                  });
                }
              } catch (e) {
                // reset
                _blockScanTimer?.cancel();
                _blockScanTimer = Timer(const Duration(seconds: 3), () {
                  WidgetsBinding.instance.addPostFrameCallback((d) {
                    setState(() {
                      _blockScan = false;
                      _showLottie = true;
                      _student = null;
                    });
                    _lottieTimer = Timer(const Duration(seconds: 3), () {
                      WidgetsBinding.instance.addPostFrameCallback((d) {
                        setState(() {
                          _showLottie = false;
                        });
                      });
                    });
                  });
                });
              }
            }
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    _blockScanTimer?.cancel();
    _lottieTimer?.cancel();
    _controller.dispose();

    super.dispose();
  }
}
