import 'package:flutter/material.dart';
import 'analysis_card.dart';



class AnalysisCenterPage extends StatelessWidget {
  const AnalysisCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('运动分析')),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(24),
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        childAspectRatio: 1.1,
        children: const [
          AnalysisEntryCard(
            icon: Icons.videocam,
            title: '单视频分析',
            mode: AnalysisMode.single,
          ),
          AnalysisEntryCard(
            icon: Icons.compare,
            title: '双视频对比',
            mode: AnalysisMode.compare,
          ),
          AnalysisEntryCard(
            icon: Icons.camera_alt,
            title: '实时分析',
            mode: AnalysisMode.realtime,
          ),
          AnalysisEntryCard(
            icon: Icons.history,
            title: '历史结果',
            mode: AnalysisMode.history,
          ),
        ],
      ),
    );
  }
}