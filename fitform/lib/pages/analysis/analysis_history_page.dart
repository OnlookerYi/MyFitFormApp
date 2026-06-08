
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fitform/models/analysis_history_item.dart';
import 'package:fitform/services/history_service.dart';
import 'package:fitform/pages/analysis/analysis_report_page.dart';

/// ✅ 只负责“当前用户”的历史

class AnalysisHistoryPage extends StatefulWidget {
  final int userId;

  const AnalysisHistoryPage({
    super.key,
    required this.userId,
  });

  @override
  State<AnalysisHistoryPage> createState() => _AnalysisHistoryPageState();
}

class _AnalysisHistoryPageState extends State<AnalysisHistoryPage> {
  List<AnalysisHistoryItem> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    print('📦 history raw = ${await HistoryApi.fetchHistory(6)}');
    try {
      _items = await HistoryApi.fetchHistory(widget.userId);
    } catch (_) {
      _items = [];
    }
    setState(() => _loading = false);
  }

  Color _scoreColor(int s) =>
      s >= 80 ? Colors.green : s >= 70 ? Colors.orange : Colors.red;

  String _formatDate(DateTime t) =>
      '${t.year}-${t.month.toString().padLeft(2, '0')}-${t.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('历史记录')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('历史记录')),
      body: _items.isEmpty
          ? const Center(child: Text('暂无历史分析'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemCount: _items.length,
              itemBuilder: (_, i) => _buildItem(_items[i]),
            ),
    );
  }

  Widget _buildItem(AnalysisHistoryItem h) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        leading: CircleAvatar(
          backgroundColor: _scoreColor(h.score),
          child: Text(
            '${h.score}',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          '${h.exercise} · ${h.reps} 次',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              _formatDate(h.createdAt),
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            if (h.summary != null && h.summary!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  h.summary!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AnalysisReportPage(
                score: h.score,
                exercise: h.exercise,
                reps: h.reps,
                feedback: h.summary ?? '',
                checkpoints: h.detail,
              ),
            ),
          );
        },
      ),
    );
  }
}