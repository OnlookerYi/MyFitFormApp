import 'package:flutter/material.dart';
import 'home_page.dart';
import '../analysis/analysis_center_page.dart';
import '../community/community_page.dart';
import '../profile/profile_page.dart';

final GlobalKey<HomePageState> homePageKey =
    GlobalKey<HomePageState>();

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    HomePage(key: homePageKey),
    const AnalysisCenterPage(),
    const CommunityPage(),
    const ProfilePage(),
  ];

  void _onTabTap(int index) {
    setState(() {
      _currentIndex = index;
    });

    // ✅ 切回首页时刷新语录
    if (index == 0) {
      homePageKey.currentState?.updateQuote();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTap,
        backgroundColor: Colors.lightBlue,
        selectedItemColor: Colors.amber,
        unselectedItemColor: Colors.black,
        type:BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '首页'),
          BottomNavigationBarItem(icon: Icon(Icons.analytics), label: '分析'),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: '社区'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '个人'),
        ],
      ),
    );
  }
}