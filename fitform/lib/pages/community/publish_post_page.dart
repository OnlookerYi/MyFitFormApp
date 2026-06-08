import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_compress/video_compress.dart';

import 'package:fitform/models/post.dart';
import 'package:fitform/models/workout_analysis.dart';
import 'package:fitform/services/post_service.dart';
import 'package:fitform/services/upload_service.dart';

class PublishPostPage extends StatefulWidget {
  const PublishPostPage({super.key});

  @override
  State<PublishPostPage> createState() => _PublishPostPageState();
}

class _PublishPostPageState extends State<PublishPostPage> {
  final _contentCtrl = TextEditingController();
  PostType _type = PostType.image;

  List<String> _images = [];
  String? _videoPath;
  WorkoutAnalysis? _analysis;
  int? _analysisId;
  int? currentUserId;

  bool _isPublishing = false; // ✅ 发布状态锁

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      currentUserId = prefs.getInt('userId');
    });
  }

  Future<void> _publish() async {
    if (_isPublishing) return; // ✅ 必须最先

    setState(() => _isPublishing = true); // ✅ 立刻锁

    if (currentUserId == null) {
      setState(() => _isPublishing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('未获取到用户信息，请重新登录')),
      );
      return;
    }

    final content = _contentCtrl.text.trim();
    if (content.isEmpty) {
      setState(() => _isPublishing = false);
      return;
    }

    _showLoadingDialog('正在发布...');

    try {
      List<String> imageUrls = [];

      if (_type == PostType.image) {
        for (final img in _images) {
          imageUrls.add(await UploadService.upload(File(img)));
        }
      }

      String? videoUrl;
      if (_type == PostType.video && _videoPath != null) {
        videoUrl = await UploadService.upload(File(_videoPath!));
      }

      if (_type == PostType.analysis) {
        _analysis ??= WorkoutAnalysis(
          id: 0,
          userId: currentUserId!,
          exerciseType: '深蹲',
          score: 92,
          duration: 1800,
          calories: 320,
          feedback: '动作标准',
          createdAt: DateTime.now().toString(),
        );
      }

      final post = await PostService.publishPost(
        authorId: currentUserId!,
        content: content,
        type: _type,
        images: imageUrls,
        videoUrl: videoUrl,
        analysisId: _analysisId,
      );

      if (!mounted) return;
      Navigator.pop(context); // ✅ 关 loading
      Navigator.pop(context, post);
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // ✅ 关 loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('发布失败：$e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isPublishing = false);
      }
    }
  }

  void _showLoadingDialog(String text) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(text),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickAndCompressImage() async {
    final XFile? image =
        await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    _showLoadingDialog('正在压缩图片...');

    try {
      final bytes = await image.readAsBytes();
      final dir = await getTemporaryDirectory();
      final tempPath =
          '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final tempFile = File(tempPath);
      await tempFile.writeAsBytes(bytes);

      final targetPath =
          '${dir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final result = await FlutterImageCompress.compressAndGetFile(
        tempFile.path,
        targetPath,
        quality: 70,
        minWidth: 1080,
        minHeight: 1080,
      );

      if (!mounted) return;
      Navigator.pop(context);

      if (result != null) {
        setState(() => _images.add(result.path));
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('图片压缩失败：$e')),
      );
    }
  }

  Future<void> _pickAndCompressVideo() async {
    final XFile? video =
        await _picker.pickVideo(source: ImageSource.gallery);
    if (video == null) return;

    _showLoadingDialog('正在压缩视频...');

    try {
      final info = await VideoCompress.compressVideo(
        video.path,
        quality: VideoQuality.MediumQuality,
        deleteOrigin: false,
      );

      if (!mounted) return;
      Navigator.pop(context);

      if (info?.file != null) {
        setState(() => _videoPath = info!.file!.path);
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('视频压缩失败：$e')),
      );
    }
  }

  @override
  void dispose() {
    VideoCompress.cancelCompression(); // ✅ 防止后台压缩
    _contentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: const Text('发布动态'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton(
              onPressed: _isPublishing ? null : _publish,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.green.withOpacity(0.6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 8),
              ),
              child: _isPublishing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : const Text('发布'),
            ),
          ),
        ],
      ),
      body: AbsorbPointer(
        absorbing: _isPublishing, // ✅ 发布时禁止操作页面
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SegmentedButton<PostType>(
                  selected: {_type},
                  onSelectionChanged: (v) {
                    setState(() {
                      _type = v.first;
                      _images.clear();
                      _videoPath = null;
                      _analysis = null;
                      _analysisId = null;
                    });
                  },
                  segments: const [
                    ButtonSegment(
                        value: PostType.image, label: Text('图文')),
                    ButtonSegment(
                        value: PostType.video, label: Text('视频')),
                    ButtonSegment(
                        value: PostType.analysis, label: Text('分析')),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: TextField(
                  controller: _contentCtrl,
                  maxLines: 6,
                  minLines: 4,
                  decoration: const InputDecoration(
                    hintText: '分享你的运动成果...',
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildContentType(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContentType() {
    switch (_type) {
      case PostType.image:
        return _imagePicker();
      case PostType.video:
        return _videoPicker();
      case PostType.analysis:
        return _analysisPreview();
    }
  }

  Widget _imagePicker() {
    return Column(
      children: [
        if (_images.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _images
                .map(
                  (img) => ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(img),
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                )
                .toList(),
          ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _pickAndCompressImage,
          icon: const Icon(Icons.add_photo_alternate_outlined),
          label: const Text('添加图片'),
        ),
      ],
    );
  }

  Widget _videoPicker() {
    return Column(
      children: [
        if (_videoPath != null)
          Text(
            '已选择视频',
            style: TextStyle(color: Colors.green.shade700),
          ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _pickAndCompressVideo,
          icon: const Icon(Icons.videocam_outlined),
          label: const Text('选择视频'),
        ),
      ],
    );
  }

  Widget _analysisPreview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          _analysisRow('动作', '深蹲'),
          _analysisRow('时长', '30 分钟'),
          _analysisRow('消耗', '320 kcal'),
          _analysisRow('评分', '92 分'),
        ],
      ),
    );
  }

  Widget _analysisRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(label,
              style: const TextStyle(fontSize: 14, color: Colors.grey)),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}