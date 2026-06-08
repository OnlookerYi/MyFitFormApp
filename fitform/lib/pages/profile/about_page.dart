import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('关于我们'),
        centerTitle: true,
        backgroundColor: Colors.greenAccent,
        foregroundColor: Colors.black,
      ),
      backgroundColor: const Color(0xFFF7F8FA),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildLogo(),
          const SizedBox(height: 20),
          _buildIntro(),
          const SizedBox(height: 16),
          _buildFeatures(),
          const SizedBox(height: 16),
          _buildTeam(),
          const SizedBox(height: 16),
          _buildTechStack(),
          const SizedBox(height: 16),
          _buildFooter(),
        ],
      ),
    );
  }

  /* ================= Logo ================= */

  Widget _buildLogo() {
    return Center(
      child: Column(
        children: const [
          Icon(Icons.fitness_center, size: 48, color: Colors.green),
          SizedBox(height: 12),
          Text(
            'FitForm',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'AI 智能健身助手',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  /* ================= 简介 ================= */

  Widget _buildIntro() {
    return _card(
      child: const Text(
        'FitForm 是一款基于 AI 姿态识别的智能健身应用，'
        '致力于为用户提供科学、可视化的动作分析与训练反馈，'
        '帮助用户在无器械环境下安全、高效地完成训练。',
        style: TextStyle(fontSize: 15, height: 1.6),
      ),
    );
  }

  /* ================= 核心功能 ================= */

  Widget _buildFeatures() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('核心功能',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          _FeatureItem(text: 'AI 实时姿态分析'),
          _FeatureItem(text: '动作评分与纠错建议'),
          _FeatureItem(text: '训练历史与数据统计'),
          _FeatureItem(text: '社区分享与交流'),
        ],
      ),
    );
  }

  /* ================= 团队 ================= */

  Widget _buildTeam() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('开发团队',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Text('项目名称:FitForm 智能健身系统'),
          Text('项目经理: 张书赫'),
          Text('产品经理: 张轶赫'),
          Text('技术负责人: 张书赫'),
          Text('前端开发工程师: 欧阳明威'),
          Text('后端开发工程师: 张书赫'),
          Text('测试工程师: 易满缘 周靖翔 陈汉'),
          Text('UI设计师: 张逍哲 欧阳明威'),
          Text('文档工程师: 张书赫'),
          Text('指导老师：郑馥丹'),
        ],
      ),
    );
  }

  /* ================= 技术栈 ================= */

  Widget _buildTechStack() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('技术栈',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Text('• Flutter + Dart'),
          Text('• Flask + MySQL'),
          Text('• MediaPipe Pose'),
          Text('• OpenCV'),
        ],
      ),
    );
  }

  /* ================= 底部 ================= */

  Widget _buildFooter() {
    return const Center(
      child: Text(
        '© 2026 FitForm · 毕业设计作品',
        style: TextStyle(fontSize: 13, color: Colors.grey),
      ),
    );
  }

  /* ================= 公共 Card ================= */

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}

/* ================= Feature Item ================= */

class _FeatureItem extends StatelessWidget {
  final String text;
  const _FeatureItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.check_circle, size: 18, color: Colors.green),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}