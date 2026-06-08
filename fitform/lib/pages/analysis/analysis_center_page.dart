import 'package:flutter/material.dart';
import 'analysis_card.dart';



class AnalysisCenterPage extends StatelessWidget {
  const AnalysisCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
                '运动分析',
                style: TextStyle(         // ✅ 颜色
                  fontWeight: FontWeight.w600, // ✅ 粗细
                  fontSize: 24,                // ✅ 字号（可选）
                ),
              ),
        centerTitle: true,
        elevation: 1,
        backgroundColor: Colors.deepOrangeAccent,
        ),
      body: GridView.count(
        crossAxisCount: 1,
        padding: const EdgeInsets.all(24),
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        childAspectRatio: 2.0,
        children: const [
          AnalysisEntryCard(
            icon: Icons.videocam,
            title: '单视频分析',
            mode: AnalysisMode.single,
          ),
          AnalysisEntryCard(
            icon: Icons.lock_clock,
            title: '实时分析',
            mode: AnalysisMode.realtime,
          ),
          AnalysisEntryCard(
            icon: Icons.history,
            title: '历史结果',
            mode: AnalysisMode.history,
          ),
          AnalysisEntryCard(
            icon: Icons.help_outline,
            title: '评分说明',
            mode: AnalysisMode.guideline,
          ),
        ],
      ),
    );
  }
}