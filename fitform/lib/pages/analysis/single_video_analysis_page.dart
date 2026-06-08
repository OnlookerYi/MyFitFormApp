import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:fitform/models/video_source.dart';
import 'package:fitform/viewmodels/single_video_analysis_viewmodel.dart';

class SingleVideoAnalysisPage extends StatefulWidget {
  final VideoSource source;
  final String action;

  const SingleVideoAnalysisPage({
    super.key,
    required this.source,
    required this.action,
  });

  @override
  State<SingleVideoAnalysisPage> createState() =>
      _SingleVideoAnalysisPageState();
}

class _SingleVideoAnalysisPageState extends State<SingleVideoAnalysisPage> {
  VideoPlayerController? _controller;

  Color _scoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 70) return Colors.orange;
    return Colors.red;
  }

  @override
  void initState() {
    super.initState();
    _initVideo().then((_) => _startAnalyze());
  }

  Future<void> _initVideo() async {
    final s = widget.source;
    _controller = s.type == VideoSourceType.file
        ? VideoPlayerController.file(File(s.path))
        : VideoPlayerController.networkUrl(Uri.parse(s.path));
    await _controller!.initialize();
    setState(() {});
  }

  Future<void> _startAnalyze() async {
    final vm = context.read<SingleVideoAnalysisViewModel>();
    await vm.start(widget.source.path, widget.action);

    if (vm.exercise != widget.action && vm.confidence >= 20) {
      _showActionMismatchDialog(
        detected: vm.exercise,
        expected: widget.action,
      );
    }
  }

  void _showActionMismatchDialog({
    required String detected,
    required String expected,
  }) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('动作识别不一致'),
        content: Text(
          '你选择的是 $expected\n'
          '系统识别为 $detected\n\n'
          '是否使用系统识别的结果继续评分？',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<SingleVideoAnalysisViewModel>().reset();
            },
            child: const Text('重新选择动作'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('继续使用识别结果'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<bool> _confirmExit() async {
    final vm = context.read<SingleVideoAnalysisViewModel>();
    if (vm.state != AnalyzeState.analyzing) return true;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('取消分析'),
        content: const Text('确定要取消本次分析吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('继续分析'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<SingleVideoAnalysisViewModel>().cancel();// ✅ 只在这里
              Navigator.pop(context, true);
            },
            child: const Text('取消分析'),
          ),
        ],
      ),
    );

    return confirm ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SingleVideoAnalysisViewModel>();

    return PopScope(
      canPop: vm.state != AnalyzeState.analyzing,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final allow = await _confirmExit();
        if (allow && context.mounted) Navigator.of(context).pop();
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('单视频分析')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (_controller?.value.isInitialized == true)
              LayoutBuilder(
                builder: (context, constraints) {
                  final ar = _controller!.value.aspectRatio;
                  late BoxConstraints boxConstraints;

                  if (ar >= 1) {
                    boxConstraints = BoxConstraints(
                      maxHeight: constraints.maxWidth * 0.55,
                    );
                  } else {
                    boxConstraints = BoxConstraints(
                      maxWidth: constraints.maxWidth * 0.36,
                    );
                  }

                  return Center(
                    child: ConstrainedBox(
                      constraints: boxConstraints,
                      child: AspectRatio(
                        aspectRatio: ar,
                        child: GestureDetector(
                          onTap: () {
                            if (_controller!.value.isPlaying) {
                              _controller!.pause();
                            } else {
                              _controller!.play();
                            }
                            setState(() {});
                          },
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              VideoPlayer(_controller!),
                              if (!_controller!.value.isPlaying)
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black38,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.play_arrow,
                                      size: 64, color: Colors.white),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            const SizedBox(height: 16),
            if (vm.state == AnalyzeState.uploading)
              const Center(child: Text('上传视频中...')),
            if (vm.state == AnalyzeState.queued)
              const Center(child: Text('系统繁忙，请稍后重试...')),
            if (vm.state == AnalyzeState.analyzing)
              const Center(child: CircularProgressIndicator()),
            if (vm.state == AnalyzeState.done) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _scoreColor(vm.score),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.emoji_events,
                        size: 48, color: Colors.white),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('综合得分',
                              style: TextStyle(color: Colors.white)),
                          Text(
                            '${vm.score} 分',
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '识别动作：${vm.exercise}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('完成次数：${vm.reps} 次'),
                  Row(
                    children: [
                      Icon(
                        vm.confidence >= 25
                            ? Icons.verified
                            : vm.confidence >= 20
                                ? Icons.info_outline
                                : Icons.warning_amber,
                        size: 18,
                        color: vm.confidence >= 25
                            ? Colors.green
                            : vm.confidence >= 20
                                ? Colors.orange
                                : Colors.red,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        vm.confidence >= 25
                            ? '动作识别成功'
                            : vm.confidence >= 20
                                ? '动作识别近似成功'
                                : '未识别到动作',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('详细评分',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              ...vm.checkpoints.entries.map((e) {
                final c = e.value;
                final score = (c['score'] as num).round();
                return Card(
                  color: _scoreColor(score).withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                c['feedback'] ?? '',
                                style: const TextStyle(fontSize: 15),
                              ),
                            ),
                            Text(
                              '$score 分',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: _scoreColor(score),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        LinearProgressIndicator(
                          value: score / 100,
                          backgroundColor: Colors.grey.shade300,
                          color: _scoreColor(score),
                          minHeight: 6,
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('分析与建议',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(vm.feedback),
                    ],
                  ),
                ),
              ),
            ],
            if (vm.state == AnalyzeState.failed)
              const Center(child: Text('分析失败，请重试')),
          ],
        ),
      ),
    );
  }
}