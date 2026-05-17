import 'package:flutter/material.dart';

class CompareScorePanel extends StatelessWidget {
  const CompareScorePanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: const [
          Expanded(
            child: _ScoreColumn(
              title: '用户',
              score: 82,
              color: Colors.orange,
            ),
          ),
          Expanded(
            child: _ScoreColumn(
              title: '标准',
              score: 95,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreColumn extends StatelessWidget {
  final String title;
  final int score;
  final Color color;

  const _ScoreColumn({
    required this.title,
    required this.score,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(
          '$score',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: color,
              ),
        ),
      ],
    );
  }
}