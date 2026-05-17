import 'package:flutter/material.dart';

class SingleVideoAnalysisViewModel {
  bool showSkeleton = true;

  List<Offset> currentKeypoints = [];
  List<double> kneeAngleSeries = [];
  List<double> hipAngleSeries = [];

  int score = 88;

  String get scoreLevel {
    if (score >= 90) return '优秀';
    if (score >= 75) return '良好';
    return '需改进';
  }

  void updateByFrame(int frameIndex) {
    // TODO: 从 AI 推理结果更新关键点 & 角度
  }
}


