import 'package:file_picker/file_picker.dart';
import '../models/video_source.dart';

Future<VideoSource?> pickLocalVideo() async {
  final result = await FilePicker.platform.pickFiles(
    type: FileType.video,
  );

  if (result == null || result.files.isEmpty) return null;

  return VideoSource.file(result.files.single.path!);
}