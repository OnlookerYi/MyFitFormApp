import 'package:flutter/material.dart';
import 'package:fitform/viewmodels/single_video_analysis_viewmodel.dart';

class AnalysisInfoPanel extends StatelessWidget {
  final SingleVideoAnalysisViewModel vm;

  const AnalysisInfoPanel({
    super.key,
    required this.vm,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _ScoreCard(
              score: vm.score,
              level: vm.scoreLevel,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: _PlaceholderChart(),
          ),
        ],
      ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  final int score;
  final String level;

  const _ScoreCard({
    required this.score,
    required this.level,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              '$score',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 4),
            Text(level),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: const Text('角度曲线 / AI 分析'),
    );
  }
}