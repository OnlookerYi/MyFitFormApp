import 'package:flutter/material.dart';
import 'admin_ban_page.dart';
import 'admin_report_page.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  final _tabs = const [
    Tab(text: '用户封禁'),
    Tab(text: '举报处理'),
  ];

  final _pages = const [
    AdminBanPage(),
    AdminReportPage(),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: const Text('管理员后台'),
        centerTitle: true,
        backgroundColor: Colors.lightGreenAccent,
        foregroundColor: Colors.redAccent,
        elevation: 1,
        bottom: TabBar(
          controller: _tabController,
          tabs: _tabs,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.black,
          indicatorSize: TabBarIndicatorSize.tab,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _pages,
      ),
    );
  }
}