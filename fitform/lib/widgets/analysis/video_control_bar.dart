import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoControlBar extends StatelessWidget {
  final VideoPlayerController controller;

  const VideoControlBar({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (context, VideoPlayerValue value, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.replay_10),
              onPressed: () {
                final pos = value.position - const Duration(seconds: 10);
                controller.seekTo(pos > Duration.zero ? pos : Duration.zero);
              },
            ),
            IconButton(
              iconSize: 48,
              icon: Icon(
                value.isPlaying
                    ? Icons.pause_circle_filled
                    : Icons.play_circle_fill,
              ),
              onPressed: () {
                value.isPlaying
                    ? controller.pause()
                    : controller.play();
              },
            ),
            IconButton(
              icon: const Icon(Icons.forward_10),
              onPressed: () {
                final pos = value.position + const Duration(seconds: 10);
                controller.seekTo(pos);
              },
            ),
          ],
        );
      },
    );
  }
}