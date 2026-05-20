import 'package:flutter/material.dart';
import 'dart:io';
import 'package:fitform/utils/video_picker.dart';
import 'package:fitform/models/video_source.dart';
import 'package:video_player/video_player.dart';
import 'package:fitform/widgets/analysis/analysis_info_panel.dart';
import 'package:fitform/widgets/analysis/video_control_bar.dart';
import 'package:fitform/widgets/analysis/video_progress_bar.dart';
import 'package:fitform/viewmodels/single_video_analysis_viewmodel.dart';
import 'skeleton_overlay.dart';

class SingleVideoAnalysisPage extends StatefulWidget {
  final VideoSource? source;

  const SingleVideoAnalysisPage({
    super.key,
    this.source,
  });

  @override
  State<SingleVideoAnalysisPage> createState() =>
      _SingleVideoAnalysisPageState();
}

class _SingleVideoAnalysisPageState extends State<SingleVideoAnalysisPage> {
  VideoPlayerController? _videoController;
  final vm = SingleVideoAnalysisViewModel();
  bool _isInitialized = false;

  bool get hasVideo =>
    widget.source != null &&
    widget.source!.type != VideoSourceType.camera;

  @override
  void initState() {
    super.initState();
    if(widget.source != null) {
      _initVideo();
    }
  }

  Future<void> _initVideo() async {
    if(widget.source == null) return;

    switch (widget.source!.type) {
      case VideoSourceType.network:
        _videoController = VideoPlayerController.networkUrl(
          Uri.parse(widget.source!.path),
        );
        break;
      case VideoSourceType.file:
        _videoController = VideoPlayerController.file(
          File(widget.source!.path),
        );
        break;
      case VideoSourceType.asset:
        _videoController = VideoPlayerController.asset(
          widget.source!.path,
        );
        break;
      case VideoSourceType.camera:
        return;
    }
    
    await _videoController?.initialize();
    if (mounted) setState(() => _isInitialized = true);
  }

  Future<void> _pickLocalVideo() async {
    final source = await pickLocalVideo();
    if (source == null || !mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => SingleVideoAnalysisPage(source: source),
      ),
    );
  }

  @override
  void dispose() {
    if (widget.source?.type != VideoSourceType.camera) {
      _videoController?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    if(!hasVideo) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('单视频分析'),
          actions: [
            IconButton(
              icon: const Icon(Icons.folder_open),
              tooltip: '选择本地视频',
              onPressed: _pickLocalVideo,
            ),
          ],
        ),
      );
    }

    if (!_isInitialized &&
      widget.source?.type != VideoSourceType.camera) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final controller = _videoController;

    return Scaffold(

      appBar: AppBar(
        title: const Text('单视频分析'),
        actions: [
          IconButton(
            icon: const Icon(Icons.folder_open),
            onPressed: _pickLocalVideo,
          ),
        ],
      ),

      body: Column(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              children: [
                if(controller != null)
                  VideoPlayer(controller)
                else
                  const Center(child: Text('视频未加载')),
                if (vm.showSkeleton)
                  SkeletonOverlay(keypoints: vm.currentKeypoints),
              ],
            ),
          ),
          if (controller != null)
            VideoProgressBar(controller: controller),
          Expanded(
            child: AnalysisInfoPanel(vm: vm),
          ),
          if (controller != null)
            VideoControlBar(controller: controller),
        ],
      ),
    );
  }
}