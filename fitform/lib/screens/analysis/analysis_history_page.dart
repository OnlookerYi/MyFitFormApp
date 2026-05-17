import 'package:flutter/material.dart';

class AnalysisHistoryPage extends StatelessWidget {
  const AnalysisHistoryPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('历史分析')),
      body: ListView.builder(
        itemCount: 10,
        itemBuilder: (_, i) => ListTile(
          leading: const Icon(Icons.insert_chart),
          title: Text('深蹲分析 $i'),
          subtitle: const Text('2025-12-01 18:30'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // 打开历史详情
          },
        ),
      ),
    );
  }
}