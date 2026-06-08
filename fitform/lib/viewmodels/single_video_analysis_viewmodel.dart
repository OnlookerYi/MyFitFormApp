import 'package:flutter/material.dart';
import '../services/mediapipe_api.dart';
import 'dart:io';

enum AnalyzeState {
  idle,
  uploading,
  queued,
  analyzing,
  done,
  failed,
}

class SingleVideoAnalysisViewModel extends ChangeNotifier {
  AnalyzeState state = AnalyzeState.idle;

  int score = 0;
  int reps = 0;
  int confidence = 0;
  String feedback = '';
  String exercise = '';
  String? _taskId;
  Map<String, dynamic> checkpoints = {};

  bool _mounted = true;
  bool _polling = false;

  void _safeNotify(VoidCallback fn) {
    if (!_mounted) return;
    fn();
    notifyListeners();
  }

  Future<void> start(String videoPath, String action) async {
    if (_polling) return;
    _polling = true;

    try {
      final taskId = await MediaPipeApi.analyzeVideo(
        File(videoPath),
        action,
      );
      _taskId = taskId;
      _safeNotify(() => state = AnalyzeState.uploading);

      final result = await MediaPipeApi.pollResult(
        taskId,
        onStatus: (s) {
          if (s == 'queued') _safeNotify(() => state = AnalyzeState.queued);
          if (s == 'processing') {
            _safeNotify(() => state = AnalyzeState.analyzing);
          }
        },
      );

      _safeNotify(() {
        score = (result['score'] as num?)?.round() ?? 0;
        reps = (result['reps'] as num?)?.round() ?? 0;
        confidence = (result['confidence'] as num?)?.round() ?? 0;
        feedback = (result['summary'] as List).join('\n');
        exercise = result['exercise'] ?? '';
        checkpoints = Map<String, dynamic>.from(result['checkpoints'] ?? {});
        state = AnalyzeState.done;
      });
    } catch (e) {
      if (e.toString().contains('已取消')) return;
      _safeNotify(() => state = AnalyzeState.failed);
    } finally {
      _polling = false;
    }
  }

  void reset() {
    _safeNotify(() {
      state = AnalyzeState.idle;
      score = reps = confidence = 0;
      feedback = exercise = '';
      checkpoints.clear();
    });
  }
  Future<void> cancel() async {
    if (_taskId == null) return;
    await MediaPipeApi.cancel(_taskId!);
  }
  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }
}