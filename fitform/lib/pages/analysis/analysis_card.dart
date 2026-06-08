import 'package:fitform/pages/analysis/real_time_analysis_page.dart';
import 'package:flutter/material.dart';
import 'analysis_history_page.dart';
import 'action_select_page.dart';
import 'analysis_guidelines_page.dart';
import 'package:fitform/services/user_service.dart';

enum AnalysisMode {
  single,
  history,
  realtime,
  guideline,
}
double cardHeight(BuildContext context) {
  final screenHeight = MediaQuery.of(context).size.height;
  return screenHeight * 0.32; // ✅ 手机越高，卡片越高
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

  Color _cardColor() {
    switch (mode) {
      case AnalysisMode.single:
        return Colors.lightBlue; // 蓝
      case AnalysisMode.history:
        return Colors.lightGreen; 
      case AnalysisMode.realtime:
        return Colors.lime;
      case AnalysisMode.guideline:
        return Colors.redAccent; // 橙
    }
  }


  Color _iconColor() {
    switch (mode) {
      case AnalysisMode.single:
        return const Color(0xFF2563EB);
      case AnalysisMode.history:
        return const Color(0xFF16A34A);
      case AnalysisMode.realtime:
        return const Color(0xFFEA580C);
      case AnalysisMode.guideline:
        return const Color(0xFFEA580C);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      color: _cardColor(),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: cardHeight(context), // ✅ 关键：提升卡片高度
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _navigate(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 28,
              horizontal: 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 32,
                    color: _iconColor(),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigate(BuildContext context) async {
    switch (mode) {
      case AnalysisMode.single:
        if (!context.mounted) return;
        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(
            builder: (_) => const ActionSelectPage(),
          ),
        );
        break;

      case AnalysisMode.realtime:
        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(
            builder: (_) => const RealTimeAnalysisPage(),
          ),
        );
        break;

      case AnalysisMode.history:
        final userId = await UserService.getCurrentUserId();
        if (userId == null) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('请先登录')),
          );
          return;
        }
        if (!context.mounted) return;
        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(
            builder: (_) => AnalysisHistoryPage(userId: userId),
          ),
        );
        break;

      case AnalysisMode.guideline:
        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(
            builder: (_) => const ScoringGuidePage(),
          ),
        );
        break;
    }
  }
}