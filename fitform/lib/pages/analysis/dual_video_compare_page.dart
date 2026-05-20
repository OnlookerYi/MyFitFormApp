import 'package:fitform/models/video_source.dart';
import 'package:flutter/material.dart';
import 'single_video_analysis_page.dart';
import 'package:fitform/widgets/analysis/compare_score_panel.dart';

class DualVideoComparePage extends StatelessWidget {
  const DualVideoComparePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('动作对比分析'),
      ),
      body: Column(
        children: [
          // ✅ 视频区（左右对比）
          Expanded(
            child: Row(
              children: [
                // 用户视频
                Expanded(
                  child: SingleVideoAnalysisPage(),
                ),

                const VerticalDivider(
                  width: 1,
                  thickness: 1,
                ),

                // 标准动作视频
                Expanded(
                  child: SingleVideoAnalysisPage(),
                ),
              ],
            ),
          ),
          // ✅ 对比评分面板
          const CompareScorePanel(),

          // ✅ 底部控制栏（可选）
          // 通常对比页不加单独控制栏
        ],
      ),
    );
  }
}