import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_compress/video_compress.dart';

import 'package:fitform/models/video_source.dart';
import 'package:fitform/utils/video_picker.dart';
import 'package:fitform/pages/analysis/single_video_analysis_page.dart';
import 'package:fitform/viewmodels/single_video_analysis_viewmodel.dart';

class ActionSelectPage extends StatelessWidget {
  const ActionSelectPage({super.key});

  static const _actions = [
    _ActionMeta(Icons.accessibility_new, '深蹲', 'squat', Color(0xFF6C9BD2)),
    _ActionMeta(Icons.sports_gymnastics, '俯卧撑', 'pushup', Color(0xFFFF8A65)),
    _ActionMeta(Icons.directions_walk, '弓步蹲', 'lunge', Color(0xFF9575CD)),
    _ActionMeta(Icons.horizontal_rule, '平板支撑', 'plank', Color(0xFF4DB6AC)),
    _ActionMeta(Icons.fitness_center, '卷腹', 'crunch', Color(0xFFFFD54F)),
    _ActionMeta(Icons.sports_handball, '罗马尼亚硬拉', 'rdl', Color(0xFFEF5350)),
    _ActionMeta(Icons.airline_seat_flat, '卧推', 'bench', Color(0xFF90CAF9)),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('选择训练动作')),
      body: GridView.count(
        crossAxisCount: 2,
        childAspectRatio: 0.92,
        padding: const EdgeInsets.all(16),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: _actions
            .map((a) => ActionItem(
                  icon: a.icon,
                  title: a.title,
                  action: a.action,
                  accent: a.accent,
                ))
            .toList(),
      ),
    );
  }
}

class _ActionMeta {
  final IconData icon;
  final String title;
  final String action;
  final Color accent;

  const _ActionMeta(this.icon, this.title, this.action, this.accent);
}

class ActionItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String action;
  final Color accent;

  const ActionItem({
    super.key,
    required this.icon,
    required this.title,
    required this.action,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () => _onTap(context),
      borderRadius: BorderRadius.circular(20),
      child: Card(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, size: 56, color: accent),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'FitForm 自动识别',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onTap(BuildContext context) async {
    final source = await VideoPicker.pickFromGallery();
    if (source == null) return;
    if (!context.mounted) return;

    final file = File(source.path);

      /// ✅ 1. 文件大小限制（≤ 80 MB）
    final fileSize = await file.length();
    const maxBytes = 80 * 1024 * 1024; // 80 MB

    if (fileSize > maxBytes) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('视频不能超过 80MB')),
        );
      }
      return;
    }

    /// ✅ 1. 校验时长（≤ 30 秒）
    final mediaInfo = await VideoCompress.getMediaInfo(file.path);
    if (mediaInfo.duration == null || mediaInfo.duration! > 30000) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('视频不能超过 30 秒')),
        );
      }
      return;
    }

    /// ✅ loading
    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('正在压缩视频...'),
            ],
          ),
        ),
      );
    }

    /// ✅ 2. 极轻压缩（只降分辨率，不折腾编码）
    final info = await VideoCompress.compressVideo(
      file.path,
      quality: VideoQuality.LowQuality, // ✅ 最快
      deleteOrigin: false,
    );

    if (context.mounted) Navigator.of(context).pop(); // 关 loading

    if (info == null || info.path == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('视频处理失败')),
        );
      }
      return;
    }

    if (!context.mounted) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => SingleVideoAnalysisViewModel(),
          child: SingleVideoAnalysisPage(
            source: VideoSource(
              info.path!,
              VideoSourceType.file,
            ),
            action: action,
          ),
        ),
      ),
    );
  }
}