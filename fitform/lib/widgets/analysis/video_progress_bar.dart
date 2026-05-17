import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';

class VideoProgressBar extends StatelessWidget {
  final VideoPlayerController controller;

  const VideoProgressBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (context, VideoPlayerValue value, _) {
        final pos = value.position.inMilliseconds.toDouble();
        final total = value.duration.inMilliseconds.toDouble();

        return Slider(
          value: pos.clamp(0, total),
          max: total,
          onChanged: (v) {
            controller.seekTo(Duration(milliseconds: v.toInt()));
          },
        );
      },
    );
  }
}