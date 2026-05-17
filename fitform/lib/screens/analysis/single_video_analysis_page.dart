import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:fitform/widgets/analysis/analysis_info_panel.dart';
import 'package:fitform/widgets/analysis/video_control_bar.dart';
import 'package:fitform/widgets/analysis/video_progress_bar.dart';
import 'package:fitform/viewmodels/single_video_analysis_viewmodel.dart';
import './skeleton_overlay.dart';
class SingleVideoAnalysisPage extends StatefulWidget {
  final String videoUrl;

  const SingleVideoAnalysisPage({
    super.key,
    required this.videoUrl,
  });

  @override
  State<SingleVideoAnalysisPage> createState() =>
      _SingleVideoAnalysisPageState();
}

class _SingleVideoAnalysisPageState extends State<SingleVideoAnalysisPage> {
  late VideoPlayerController _videoController;
  final vm = SingleVideoAnalysisViewModel();

  @override
  void initState() {
    super.initState();
    _videoController = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl),);
    
    _videoController.initialize().then((_) {
        setState(() {});
    });
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('单视频分析')),
      body: Column(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              children: [
                VideoPlayer(_videoController),
                if (vm.showSkeleton)
                  SkeletonOverlay(
                    keypoints: vm.currentKeypoints,
                  ),
              ],
            ),
          ),
          VideoProgressBar(controller: _videoController),
          Expanded(
            child: AnalysisInfoPanel(vm: vm),
          ),
          VideoControlBar(controller: _videoController),
        ],
      ),
    );
  }
}




