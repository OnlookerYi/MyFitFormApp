import 'package:flutter/material.dart';
import 'home_screen.dart';
import '../analysis/analysis_screen.dart';
import '../community/feed_screen.dart';
import '../profile/profile_screen.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    AnalysisCenterPage(),
    CommunityPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
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