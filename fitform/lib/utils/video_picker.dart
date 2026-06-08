
import 'package:image_picker/image_picker.dart';
import 'package:fitform/models/video_source.dart';

class VideoPicker {
  static final ImagePicker _picker = ImagePicker();

  /// 从相册选择视频
  static Future<VideoSource?> pickFromGallery() async {
    final XFile? file =
        await _picker.pickVideo(source: ImageSource.gallery);
    if (file == null) return null;
    return VideoSource(file.path, VideoSourceType.file);
  }

  /// 从相机录制视频
  static Future<VideoSource?> recordFromCamera() async {
    final XFile? file =
        await _picker.pickVideo(source: ImageSource.camera);
    if (file == null) return null;
    return VideoSource(file.path, VideoSourceType.file);
  }
}