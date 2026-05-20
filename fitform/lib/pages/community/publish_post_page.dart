import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:fitform/models/post.dart';
import 'package:fitform/models/workout_analysis.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fitform/services/post_service.dart';
import 'package:fitform/services/analysis_sercvice.dart';
import 'package:fitform/services/upload_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  /// ✅ 当前登录用户（登录后从本地取）
  int? currentUserId;

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
  final content = _contentCtrl.text.trim();
  if (content.isEmpty) return;

  try {
    List<String> imageUrls = [];

    /// ✅ 上传图片
    if (_type == PostType.image) {
      for (final img in _images) {
        final url = await UploadService.upload(File(img));
        imageUrls.add(url);
      }
    }

    /// ✅ 上传视频
    String? videoUrl;
    if (_type == PostType.video && _videoPath != null) {
      videoUrl = await UploadService.upload(File(_videoPath!));
    }

    /// ✅ 分析
    int? analysisId;
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
      analysisId = await AnalysisService.createAnalysis(_analysis!);
    }

    final post = await PostService.publishPost(
      authorId: currentUserId!,
      content: content,
      type: _type,
      images: imageUrls,
      videoUrl: videoUrl,
      analysisId: analysisId,
    );

    if (!mounted) return;
    Navigator.pop(context, post);
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('发布失败：$e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('发布'),
        actions: [
          TextButton(
            onPressed: _publish,
            child: const Text('发布'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// ✅ 类型选择
            SegmentedButton<PostType>(
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
                  value: PostType.image,
                  label: Text('图文'),
                ),
                ButtonSegment(
                  value: PostType.video,
                  label: Text('视频'),
                ),
                ButtonSegment(
                  value: PostType.analysis,
                  label: Text('分析'),
                ),
              ],
            ),

            const SizedBox(height: 16),

            /// ✅ 内容输入
            Expanded(
              child: TextField(
                controller: _contentCtrl,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: '分享你的运动成果...',
                  border: InputBorder.none,
                ),
              ),
            ),
            /// ✅ 类型相关内容
            _buildContentType(),
          ],
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

  final ImagePicker _picker = ImagePicker();

  Widget _imagePicker() {
    return OutlinedButton.icon(
      onPressed: () async {
        final XFile? image = await _picker.pickImage(
          source: ImageSource.gallery,
        );

        if (image != null) {
          final bytes = await image.readAsBytes();
          final dir = await getTemporaryDirectory();
          final safePath =
              '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';

          final file = File(safePath);
          await file.writeAsBytes(bytes);

          setState(() {
            _images = [safePath];
          });
        }
      },
      icon: const Icon(Icons.image),
      label: const Text('选择图片'),
    );
  }

  Widget _videoPicker() {
    return OutlinedButton.icon(
      onPressed: () async {
        final XFile? video = await _picker.pickVideo(
        source: ImageSource.gallery,
      );

      if (video != null) {
        setState(() {
          _videoPath = video.path;
        });
      }
      },
    icon: const Icon(Icons.videocam),
    label: const Text('选择视频'),
    );
  }

  Widget _analysisPreview() {
    return Column(
      children: [
        ListTile(
          dense: true,
          title: const Text('动作：深蹲'),
          subtitle: const Text('下次可接入真实分析数据'),
        ),
        ListTile(
          dense: true,
          title: const Text('时长：30 min'),
        ),
        ListTile(
          dense: true,
          title: const Text('消耗：320 kcal'),
        ),
        ListTile(
          dense: true,
          title: const Text('评分：92 分'),
        ),
      ],
    );
  }
}