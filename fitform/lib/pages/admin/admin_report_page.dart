import 'package:flutter/material.dart';
import 'package:fitform/services/admin_service.dart';

class AdminReportPage extends StatefulWidget {
  const AdminReportPage({super.key});

  @override
  State<AdminReportPage> createState() => _AdminReportPageState();
}

class _AdminReportPageState extends State<AdminReportPage> {
  List<Map<String, dynamic>> _reports = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    try {
      final data = await AdminService.getReports();
      if (mounted) {
        setState(() {
          _reports = data;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('加载失败：$e')),
      );
    }
  }

  Color _statusColor(String? status) {
    switch (status) {
      case 'resolved':
        return Colors.green;
      case 'ignored':
        return Colors.grey;
      default:
        return Colors.orange;
    }
  }

  String _statusText(String? status) {
    switch (status) {
      case 'resolved':
        return '已处理';
      case 'ignored':
        return '已忽略';
      default:
        return '待处理';
    }
  }

  Future<void> _handleAction(
    int id,
    Future<void> Function(int) action,
  ) async {
    try {
      await action(id);
      _loadReports();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('操作失败：$e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: _reports.isEmpty
          ? const Center(child: Text('暂无举报'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _reports.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final r = _reports[i];
                final status = r['status'] as String?;

                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '举报人：${r['reporter_name'] ?? '未知'}',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _statusColor(status),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              _statusText(status),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '类型：${r['target_type']}  ID：${r['target_id']}',
                        style: const TextStyle(fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '原因：${r['reason'] ?? '未填写'}',
                        style: const TextStyle(fontSize: 13),
                      ),
                      const SizedBox(height: 10),
                      if (status == 'pending')
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => _handleAction(
                                r['id'],
                                AdminService.ignoreReport,
                              ),
                              child: const Text('忽略'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () => _handleAction(
                                r['id'],
                                AdminService.resolveReport,
                              ),
                              child: const Text('处理'),
                            ),
                          ],
                        ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}