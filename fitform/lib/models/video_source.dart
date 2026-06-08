enum VideoSourceType { camera, file, network, asset }

class VideoSource {
  final String path;
  final VideoSourceType type;

  const VideoSource(this.path, this.type); // ✅ 关键
}