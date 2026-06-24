import 'package:flutter/material.dart';
import 'package:fitform/services/admin_service.dart';

class AdminBanPage extends StatefulWidget {
  const AdminBanPage({super.key});

  @override
  State<AdminBanPage> createState() => _AdminBanPageState();
}

class _AdminBanPageState extends State<AdminBanPage> {
  List<Map<String, dynamic>> _users = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      final users = await AdminService.getAllUsers();
      if (mounted) {
        setState(() {
          _users = users;
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

  Future<void> _handleBan(Map<String, dynamic> user) async {
    final banned = user['banned'] == true;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(banned ? '解封用户' : '封禁用户'),
        content: Text(
          banned
              ? '确定要解封「${user['nickname']}」吗？'
              : '确定要封禁「${user['nickname']}」吗？',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(banned ? '解封' : '封禁'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      if (banned) {
        await AdminService.unbanUser(user['id']);
      } else {
        await AdminService.banUser(user['id']);
      }
      _loadUsers();
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
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _users.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) {
          final user = _users[i];
          final banned = user['banned'] == true;

          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundImage: (user['avatar'] != null &&
                          user['avatar'].toString().startsWith('http'))
                      ? NetworkImage(user['avatar'])
                      : null,
                  child: (user['avatar'] == null || user['avatar'].isEmpty)
                      ? const Icon(Icons.person)
                      : null,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user['nickname'] ?? '未知用户',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        banned ? '已封禁' : '正常',
                        style: TextStyle(
                          fontSize: 13,
                          color: banned ? Colors.red : Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _handleBan(user),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        banned ? Colors.green : Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(banned ? '解封' : '封禁'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}