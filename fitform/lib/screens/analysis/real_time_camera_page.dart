import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class RealtimeCameraPage extends StatefulWidget {
  const RealtimeCameraPage({super.key});

  @override
  State<RealtimeCameraPage> createState() => _RealtimeCameraPageState();
}

class _RealtimeCameraPageState extends State<RealtimeCameraPage> {
  late CameraController _cameraController;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    _cameraController = CameraController(
      await availableCameras().then((v) => v.first),
      ResolutionPreset.high,
    );
    await _cameraController.initialize();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!_cameraController.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    return CameraPreview(_cameraController);
  }
}