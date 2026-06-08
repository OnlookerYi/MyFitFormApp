import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fitform/models/user.dart';
import 'package:fitform/services/quote_service.dart';
import 'package:fitform/services/user_service.dart';
import 'package:fitform/services/home_status_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitform/utils/app_colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  Color quoteColor = Colors.lightBlueAccent;
  String quote = '';
  User? currentUser;
  HomeStatus? status;   // ✅ 新增
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }
  

  Future<void> _loadData() async {
    await QuoteService.loadQuotes();

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    if (userId == null) return;

    final user = await UserService.getProfile(userId);
    final st = await HomeStatusService.getStatus(userId);

    if (mounted) {
      setState(() {
        currentUser = user;
        status = st;
        loading = false;
      });
    }
  }

  /// ✅ 不改动 quote 服务
  void updateQuote() {
    setState(() {
      _loadData();
      quote = QuoteService.randomQuote();
      quoteColor = AppColors.quoteColors[
        DateTime.now().millisecondsSinceEpoch % AppColors.quoteColors.length
      ];
    });
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 11) return '早上好';
    if (h < 17) return '下午好';
    return '晚上好';
  }

  @override
  Widget build(BuildContext context) {
    if (loading || currentUser == null || status == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final size = MediaQuery.of(context).size;
    final diagonal =
        sqrt(size.width * size.width + size.height * size.height);

    return Scaffold(
      appBar: AppBar(
        title: Text(
                'FitForm',
                style: TextStyle(         // ✅ 颜色
                  fontWeight: FontWeight.w600, // ✅ 粗细
                  fontSize: 26,                // ✅ 字号（可选）
                ),
              ),
        centerTitle: true,
        backgroundColor: const Color(0xF0FFFF07),
        ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          /// ✅ 问候
          Text(
            '${_greeting()}, ${currentUser!.nickname} 👋',
            style: TextStyle(
              fontSize: diagonal * 0.03,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          /// ✅ 语录卡片（不动 quote 逻辑）
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.lightBlueAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.lightBlueAccent.withOpacity(0.2),
              ),
            ),
            child: Text(
              '"$quote"',
              style: TextStyle(
                fontSize: diagonal * 0.02,
                fontStyle: FontStyle.italic,
                color: quoteColor,
                height: 1.5,
              ),
            ),
          ),

          const SizedBox(height: 20),

          /// ✅ 今日状态（真实数据）
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    status!.checkedIn
                        ? Icons.check_circle
                        : Icons.directions_run,
                    color: status!.checkedIn ? Colors.green : Colors.orange,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '连续打卡 ${status!.streak} 天',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          status!.checkedIn
                              ? '今日已完成 ${status!.duration} 分钟运动 💪'
                              : '还没记录运动，今天准备练什么？',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: updateQuote,
        backgroundColor: Colors.lightBlueAccent,
        tooltip: '换一句鼓励',
        child: const Icon(Icons.autorenew),
      ),
    );
  }
}