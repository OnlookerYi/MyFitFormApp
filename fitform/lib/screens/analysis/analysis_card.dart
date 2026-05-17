import 'package:flutter/material.dart';
import './real_time_camera_page.dart';
import './single_video_analysis_page.dart';
import './dual_video_compare_page.dart';
import './analysis_history_page.dart';

enum AnalysisMode {
  single,
  compare,
  realtime,
  history,
}

class AnalysisEntryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final AnalysisMode mode;

  const AnalysisEntryCard({
    super.key,
    required this.icon,
    required this.title,
    required this.mode,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _navigate(context),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 12),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }

  void _navigate(BuildContext context) {
    switch (mode) {
      case AnalysisMode.single:
        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(builder: (_) => const SingleVideoAnalysisPage(videoUrl: 'https://www.python.org')),
        );
        break;
      case AnalysisMode.compare:
        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(builder: (_) => const DualVideoComparePage()),
        );
        break;
      case AnalysisMode.realtime:
        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(builder: (_) => const RealtimeCameraPage()),
        );
        break;
      case AnalysisMode.history:
        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(builder: (_) => const AnalysisHistoryPage()),
        );
        break;
    }
  }
}