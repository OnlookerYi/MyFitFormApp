import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class RealtimeCameraPage extends StatefulWidget {
  const RealtimeCameraPage({super.key});

  @override
  State<RealtimeCameraPage> createState() => _RealtimeCameraPageState();
}

class _RealtimeCameraPageState extends State<RealtimeCameraPage> {
  CameraController? _cameraController;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
  final cameras = await availableCameras();
  if (cameras.isEmpty) return;

  _cameraController = CameraController(
    cameras.first,
    ResolutionPreset.high,
  );

  await _cameraController!.initialize();
  if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final controller = _cameraController;

    if (controller == null || !controller.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    return CameraPreview(controller);
  }
}