import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fitform/widgets/common/app_titletext.dart';
import 'package:fitform/screens/auth/login_screen.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: const Text('个人中心'),
        backgroundColor: Colors.greenAccent,
        foregroundColor: Colors.black,
        centerTitle: true,
      ),
      body: ListView(
        children: [
          const _UserInfoSection(),
          const _StatsSection(),
          const SizedBox(height: 12),
          const _MenuSection(),
          const SizedBox(height: 24),
          const _LogoutButton(),
        ],
      ),
    );
  }
}


class _LogoutButton extends StatelessWidget {
  const _LogoutButton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () {
          Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginPage()),
            (route) => false,
          );
        },
        child: Text(
          '退出登录',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.amber)
        ),
      ),
    );
  }
}

class _UserInfoSection extends StatelessWidget {
  const _UserInfoSection();

  @override
  Widget build(BuildContext context) {

    final size = MediaQuery.of(context).size;
    final width = size.width;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          CircleAvatar(
            radius: width * 0.06 ,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TitleText(
                  'FitMaster',
                  style: TitleTextStyle.titleLarge,
                ),
                SizedBox(height: width * 0.01),
                Text(
                  '坚持健身第 42 天 🔥',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsSection extends StatelessWidget {
  const _StatsSection();

  @override
  Widget build(BuildContext context) {

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: const [
          _StatItem(label: '帖子', value: '36'),
          _StatItem(label: '粉丝', value: '128'),
          _StatItem(label: '关注', value: '56'),
          _StatItem(label: '点赞', value: '16'),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {

    final size = MediaQuery.of(context).size;
    final diagonal = sqrt(size.width * size.width + size.height * size.height);


    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: diagonal * 0.03 , fontWeight: FontWeight.w700)),
        SizedBox(height: diagonal * 0.01),
        Text(
          label, 
          style: TextStyle(
            fontSize: diagonal * 0.02, fontWeight: FontWeight.w500
          )
        ),
      ],
    );
  }
}

class _MenuSection extends StatelessWidget {
  const _MenuSection();

  @override
  Widget build(BuildContext context) {


    return Column(
      children: [
        _MenuItem(icon: Icons.fitness_center, title: '我的计划'),
        const SizedBox(height: 5),
        _MenuItem(icon: Icons.emoji_events, title: '我的成就'),
        const SizedBox(height: 5),
        _MenuItem(icon: Icons.bookmark_border, title: '我的收藏'),
        const SizedBox(height: 5),
        _MenuItem(icon: Icons.abc_outlined, title: '达人认证'),
        const SizedBox(height: 5),
        _MenuItem(icon: Icons.settings, title: '设置'),
        const SizedBox(height: 5),
        _MenuItem(icon: Icons.info_outline, title: '关于我们'),
        const SizedBox(height: 5),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;

  const _MenuItem({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {

    final size = MediaQuery.of(context).size;
    final diagonal = sqrt(size.width * size.width + size.height * size.height);

    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title, style: TextStyle(fontSize: diagonal * 0.02, fontWeight: FontWeight.w400)),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {},
    );
  }
}


