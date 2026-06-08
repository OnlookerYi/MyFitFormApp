import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pose_detection/flutter_pose_detection.dart';
import 'package:permission_handler/permission_handler.dart';

enum ExerciseType {
  unknown,
  stand,
  squat,
  lunge,
  crunch,
  pushUp,
  plank,
  bend,
}


class RealTimeAnalysisPage extends StatefulWidget {
  const RealTimeAnalysisPage({super.key});

  @override
  State<RealTimeAnalysisPage> createState() => _RealTimeAnalysisPageState();
}

class _RealTimeAnalysisPageState extends State<RealTimeAnalysisPage> {
  CameraController? _controller;
  NpuPoseDetector? _detector;

  bool _ready = false;

  List<PoseLandmark> _landmarks = [];

  ExerciseType _exercise = ExerciseType.unknown;
  String _quality = '等待动作';

  double _kneeL = 0;
  double _kneeR = 0;
  double _hip = 0;
  double _spine = 0;
  double _elbow = 0;

  int _squatReps = 0;
  int _lungeReps = 0;
  int _crunchReps = 0;
  int _pushUpReps = 0;

  String _phase = 'up';

  /// 用于平滑角度
  final Map<String, List<double>> _buffer = {};

  Size _imageSize = Size.zero;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    if (!(await Permission.camera.request()).isGranted) return;

    _detector = NpuPoseDetector(config: PoseDetectorConfig.realtime());
    await _detector!.initialize();

    final cameras = await availableCameras();
    final front = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
    );

    _controller = CameraController(
      front,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );

    await _controller!.initialize();
    if (!mounted) return;

    setState(() => _ready = true);

    _controller!.startImageStream(_onFrame);
  }

  void _onFrame(CameraImage image) async {
    final bytes = _yuv420ToNv21(image);
    final result = await _detector!.detectPose(bytes);

    if (!result.hasPoses) return;

    final lm = result.poses.first.landmarks
        .map(_mirrorFrontCamera)
        .toList();

    _imageSize = Size(
      image.width.toDouble(),
      image.height.toDouble(),
    );

    final kl = _smooth('kl', _angle(lm[23], lm[25], lm[27]));
    final kr = _smooth('kr', _angle(lm[24], lm[26], lm[28]));
    final hip = _smooth('hip', _angle(lm[11], lm[23], lm[25]));
    final spine = _smooth('spine', _angle(lm[11], lm[23], lm[27]));
    final elbow = _smooth(
      'elbow',
      _angle(lm[11], lm[13], lm[15]),
    );

    final ex = _detect(kl, kr, hip, spine, elbow);

    setState(() {
      _landmarks = lm;
      _kneeL = kl;
      _kneeR = kr;
      _hip = hip;
      _spine = spine;
      _elbow = elbow;
      _exercise = ex;
      _quality = _evaluate(ex);
      _countReps(ex, kl, kr, elbow, spine);
    });
  }

  /// ✅ 前置摄像头正确镜像
  PoseLandmark _mirrorFrontCamera(PoseLandmark l) => PoseLandmark(
        type: l.type,
        x: 1 - l.x,
        y: l.y,
        z: l.z,
        visibility: l.visibility,
      );

  double _smooth(String key, double v) {
    _buffer.putIfAbsent(key, () => []);
    _buffer[key]!.add(v);
    if (_buffer[key]!.length > 5) _buffer[key]!.removeAt(0);
    return _buffer[key]!.reduce((a, b) => a + b) / _buffer[key]!.length;
  }

  ExerciseType _detect(double kl, double kr, double hip, double spine, double elbow) {
    if (kl < 95 && kr < 95 && hip < 100) return ExerciseType.squat;
    if ((kl < 95 && kr > 140) || (kr < 95 && kl > 140)) return ExerciseType.lunge;
    if (elbow < 90 && hip < 100) return ExerciseType.pushUp;
    if (spine < 55) return ExerciseType.crunch;
    if (spine > 150 && kl > 160) return ExerciseType.plank;
    if (kl > 160 && kr > 160) return ExerciseType.stand;
    return ExerciseType.unknown;
  }

  void _countReps(
    ExerciseType ex,
    double kl,
    double kr,
    double elbow,
    double spine,
  ) {
    switch (ex) {
      case ExerciseType.squat:
        if (kl < 90 && _phase == 'up') _phase = 'down';
        if (kl > 160 && _phase == 'down') {
          _phase = 'up';
          _squatReps++;
        }
        break;
      case ExerciseType.lunge:
        if ((kl < 90 || kr < 90) && _phase == 'up') _phase = 'down';
        if (kl > 150 && kr > 150 && _phase == 'down') {
          _phase = 'up';
          _lungeReps++;
        }
        break;
      case ExerciseType.crunch:
        if (spine < 55 && _phase == 'up') _phase = 'down';
        if (spine > 70 && _phase == 'down') {
          _phase = 'up';
          _crunchReps++;
        }
        break;
      case ExerciseType.pushUp:
        if (elbow < 80 && _phase == 'up') _phase = 'down';
        if (elbow > 140 && _phase == 'down') {
          _phase = 'up';
          _pushUpReps++;
        }
        break;
      default:
        break;
    }
  }

  String _evaluate(ExerciseType e) {
    switch (e) {
      case ExerciseType.squat:
        return '深蹲中';
      case ExerciseType.lunge:
        return '弓步中';
      case ExerciseType.crunch:
        return '卷腹中';
      case ExerciseType.pushUp:
        return '俯卧撑中';
      case ExerciseType.plank:
        return '平板支撑 ✓';
      default:
        return '等待动作…';
    }
  }

  double _angle(PoseLandmark a, PoseLandmark b, PoseLandmark c) {
    final ab = [a.x - b.x, a.y - b.y];
    final cb = [c.x - b.x, c.y - b.y];
    final dot = ab[0] * cb[0] + ab[1] * cb[1];
    final ma = sqrt(ab[0] * ab[0] + ab[1] * ab[1]);
    final mb = sqrt(cb[0] * cb[0] + cb[1] * cb[1]);
    return acos((dot / (ma * mb)).clamp(-1, 1)) * 180 / pi;
  }

  Uint8List _yuv420ToNv21(CameraImage image) {
    final y = image.planes[0].bytes;
    final u = image.planes[1].bytes;
    final v = image.planes[2].bytes;

    final nv21 = Uint8List(y.length + u.length + v.length);
    nv21.setRange(0, y.length, y);

    for (int i = 0; i < u.length; i++) {
      nv21[y.length + i * 2] = v[i];
      nv21[y.length + i * 2 + 1] = u[i];
    }
    return nv21;
  }

  @override
  void dispose() {
    _controller?.stopImageStream();
    _controller?.dispose();
    _detector?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          CameraPreview(_controller!),
          LayoutBuilder(
            builder: (_, c) => CustomPaint(
              size: c.biggest,
              painter: PosePainter(
                _landmarks,
                _imageSize,
                c.biggest,
              )
            ),
          ),
          Positioned(
            left: 16,
            bottom: 80,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _exercise.name.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.cyanAccent,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text('左膝: ${_kneeL.toStringAsFixed(1)}°', style: sub()),
                Text('右膝: ${_kneeR.toStringAsFixed(1)}°', style: sub()),
                Text('髋: ${_hip.toStringAsFixed(1)}°', style: sub()),
                Text('脊柱: ${_spine.toStringAsFixed(1)}°', style: sub()),
                Text('肘: ${_elbow.toStringAsFixed(1)}°', style: sub()),
                Text(
                  'Squat:$_squatReps  Lunge:$_lungeReps  Crunch:$_crunchReps  PushUp:$_pushUpReps',
                  style: sub(),
                ),
                Text(_quality, style: sub()),
              ],
            ),
          )
        ],
      ),
    );
  }

  TextStyle sub() =>
      const TextStyle(color: Colors.white70, fontSize: 13);
}



class PosePainter extends CustomPainter {
  final List<PoseLandmark> landmarks;
  final Size imageSize;
  final Size canvasSize;

  PosePainter(this.landmarks, this.imageSize, this.canvasSize);

  Offset _toScreen(PoseLandmark l) {
    final scaleX = canvasSize.width / imageSize.width;
    final scaleY = canvasSize.height / imageSize.height;
    return Offset(l.x * imageSize.width * scaleX,
        l.y * imageSize.height * scaleY);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..color = Colors.greenAccent
      ..strokeWidth = 3;
    final dot = Paint()..color = Colors.greenAccent;

    for (final l in landmarks) {
      if (!l.isReliable()) continue;
      canvas.drawCircle(_toScreen(l), 4, dot);
    }

    void d(int a, int b) {
      if (!landmarks[a].isReliable() || !landmarks[b].isReliable()) return;
      canvas.drawLine(_toScreen(landmarks[a]), _toScreen(landmarks[b]), line);
    }

    d(11, 12);
    d(11, 23);
    d(12, 24);
    d(23, 24);
    d(23, 25);
    d(25, 27);
    d(24, 26);
    d(26, 28);
    d(11, 13);
    d(13, 15);
    d(12, 14);
    d(14, 16);
  }

  @override
  bool shouldRepaint(covariant PosePainter old) => true;
}