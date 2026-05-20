import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fitform/models/user.dart';
import 'package:fitform/services/quote_service.dart';
import 'package:fitform/services/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  String quote = '';
  User? currentUser;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }


  Future<void> _loadData() async {
    // ✅ 你的本地语录服务（不动）
    await QuoteService.loadQuotes();

    // ✅ 只新增：从后端拿当前用户
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');

    final user = await UserService.getProfile(userId!); // 暂写死 userId

    if (mounted) {
      setState(() {
        currentUser = user;
        quote = QuoteService.randomQuote(); // ✅ 保留原逻辑
        loading = false;
      });
    }
  }

  void updateQuote() {
    setState(() {
      quote = QuoteService.randomQuote();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('FitForm')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Greeting(quote: quote, nickname: currentUser!.nickname ?? ''),
          const SizedBox(height: 20),
          _TodayWorkoutCard(),
          const SizedBox(height: 20),
          _WeeklyStats(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: updateQuote,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}

class _Greeting extends StatelessWidget {
  final String quote;
  final String nickname;

  const _Greeting({required this.quote, required this.nickname});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final diagonal = sqrt(size.width * size.width + size.height * size.height);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '你好，$nickname 👋',
          style: TextStyle(
            fontSize: diagonal * 0.03,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          quote,
          style: TextStyle(
            fontSize: diagonal * 0.02,
            color: Colors.lightBlueAccent,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}

class _TodayWorkoutCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '今日推荐训练',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              '胸部训练 · 45 分钟',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 4),
            const Text(
              '卧推 · 夹胸 · 俯卧撑',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: 开始训练
                },
                child: const Text('开始训练'),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _WeeklyStats extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: const [
        _StatItem(label: '训练', value: '4 次'),
        _StatItem(label: '时长', value: '3.2 h'),
        _StatItem(label: '消耗', value: '1200 kcal'),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}
