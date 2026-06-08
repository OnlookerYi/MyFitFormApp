import 'package:flutter/material.dart';

class ScoringGuidePage extends StatelessWidget {
  const ScoringGuidePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FitForm 评分指南')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _GuideCard(
            icon: Icons.straight,
            title: '动作深度',
            desc: '动作是否做到标准幅度。'
                '\n深蹲：髋部低于膝盖'
                '\n俯卧撑：胸部接近地面'
                '\n卷腹：肩膀明显抬起',
          ),
          _GuideCard(
            icon: Icons.accessibility_new,
            title: '躯干控制',
            desc: '上半身是否保持稳定。'
                '\n不塌腰、不弓背、不乱晃'
                '\n像木板一样最理想。',
          ),
          _GuideCard(
            icon: Icons.directions_run,
            title: '膝关节轨迹',
            desc: '膝盖是否朝脚尖方向。'
                '\n膝盖内扣会伤膝，会被扣分。',
          ),
          _GuideCard(
            icon: Icons.vibration,
            title: '稳定性',
            desc: '动作是否流畅。'
                '\n轻微抖动正常'
                '\n大幅晃动说明核心不稳。',
          ),
          _GuideCard(
            icon: Icons.balance,
            title: '左右对称',
            desc: '左右两侧是否均衡。'
                '\n正面拍摄通常只看到一侧，会提示「仅单侧数据」，这是正常的。',
          ),
          _GuideCard(
            icon: Icons.speed,
            title: '节奏',
            desc: '动作快慢是否合理。'
                '\n太快：借力'
                '\n太慢：卡顿'
                '\n匀速最好。',
          ),
          _GuideCard(
            icon: Icons.info_outline,
            title: '特别说明',
            desc: '平板支撑：看身体是否成一条直线'
                '\n卷腹：看脖子是否放松'
                '\n弓步蹲：看两腿是否均衡',
          ),
        ],
      ),
    );
  }
}

class _GuideCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;

  const _GuideCard({
    required this.icon,
    required this.title,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 32, color: Theme.of(context).primaryColor),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(desc,
                      style: const TextStyle(fontSize: 14, height: 1.5)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}