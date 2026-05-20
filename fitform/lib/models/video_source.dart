enum VideoSourceType {
  network,
  file,
  asset,
  camera,
}

class VideoSource {
  final VideoSourceType type;
  final String path;

  const VideoSource({
    required this.type,
    required this.path,
  });

  factory VideoSource.network(String url) =>
      VideoSource(type: VideoSourceType.network, path: url);

  factory VideoSource.file(String filePath) =>
      VideoSource(type: VideoSourceType.file, path: filePath);

  factory VideoSource.asset(String assetPath) =>
      VideoSource(type: VideoSourceType.asset, path: assetPath);

  factory VideoSource.camera() =>
      const VideoSource(type: VideoSourceType.camera, path: '');
}