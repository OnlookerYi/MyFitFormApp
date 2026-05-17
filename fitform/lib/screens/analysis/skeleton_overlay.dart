import 'package:flutter/material.dart';

class SkeletonOverlay extends StatelessWidget {
  final List<Offset> keypoints;

  const SkeletonOverlay({
    super.key,
    required this.keypoints,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SkeletonPainter(keypoints),
      size: Size.infinite,
    );
  }
}

/// ✅ 这里就是报错缺失的部分
class _SkeletonPainter extends CustomPainter {
  final List<Offset> points;

  _SkeletonPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.greenAccent
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    // 画点
    for (final point in points) {
      canvas.drawCircle(point, 4, paint);
    }

    // 画骨架线（示例：0→1→2→3）
    final connections = [
      [0, 1],
      [1, 2],
      [2, 3],
    ];

    for (final c in connections) {
      if (c[0] < points.length && c[1] < points.length) {
        canvas.drawLine(points[c[0]], points[c[1]], paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SkeletonPainter old) {
    return points != old.points;
  }
}