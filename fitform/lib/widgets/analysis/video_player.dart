import 'dart:io';                         // File
import 'package:flutter/material.dart';    // Widget / StatefulWidget
import 'package:video_player/video_player.dart'; // VideoPlayerController / VideoPlayer
import 'package:fitform/models/video_source.dart'; 

class VideoPlayerWidget extends StatefulWidget {
  final VideoSource source;

  const VideoPlayerWidget({
    super.key,
    required this.source,
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final s = widget.source;
    if (s.type == VideoSourceType.file) {
      _controller = VideoPlayerController.file(File(s.path));
    } else if (s.type == VideoSourceType.network) {
      _controller = VideoPlayerController.networkUrl(Uri.parse(s.path));
    }
    await _controller?.initialize();
    setState(() {});
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller?.value.isInitialized != true) {
      return const Center(child: CircularProgressIndicator());
    }
    return VideoPlayer(_controller!);
  }
}