import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fitform/pages/community/other_user_profile_page.dart';
import 'package:fitform/models/user.dart';
import 'package:fitform/services/user_service.dart';
import 'package:fitform/pages/main/splash_page.dart';
import 'about_page.dart';
import 'edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  User? currentUser;
  bool loading = true;

  Future<void> reload() async {
    await _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');
      if (userId == null) throw Exception('未登录');

      final user = await UserService.getProfile(userId);
      if (mounted) {
        setState(() {
          currentUser = user;
          loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!mounted) return;

    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const SplashPage()),
      (route) => false,
    );
  }

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('未登录')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: const Text(
          '个人中心',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.greenAccent,
        foregroundColor: Colors.black,
        centerTitle: true,
      ),
      body: ListView(
        children: [
          _UserInfoSection(
            user: currentUser!,
            onUpdated: _loadUser,
          ),
          const SizedBox(height: 12),
          _StatsSection(user: currentUser!),
          const SizedBox(height: 12),
          _PointsCard(user: currentUser!),
          const SizedBox(height: 12),
          _MenuSection(
            currentUser: currentUser!,
            onUpdated: _loadUser,
          ),
          const SizedBox(height: 24),
          _LogoutButton(onLogout: _logout),
        ],
      ),
    );
  }
}

/* ===================== 用户信息 ===================== */

class _UserInfoSection extends StatelessWidget {
  final User user;
  final VoidCallback onUpdated;

  const _UserInfoSection({
    required this.user,
    required this.onUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EditProfilePage(
              avatarUrl: user.avatar ?? '',
              nickname: user.nickname ?? '',
              bio: user.bio ?? '',
              gender: user.gender,
            ),
          ),
        );
        onUpdated();
      },
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 36,
              backgroundImage: (user.avatar != null &&
                      user.avatar!.startsWith('http'))
                  ? NetworkImage(user.avatar!)
                  : null,
              child: (user.avatar == null || user.avatar!.isEmpty)
                  ? Text(
                      (user.nickname?.isNotEmpty == true)
                          ? user.nickname![0]
                          : user.username[0],
                      style: const TextStyle(fontSize: 24),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.nickname ?? user.username,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '用户名: ${user.username}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.bio?.isNotEmpty == true
                        ? user.bio!
                        : '暂无简介，去完善一下吧～',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ===================== 运动数据 ===================== */

class _StatsSection extends StatelessWidget {
  final User user;

  const _StatsSection({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(label: '帖子', value: '${user.postCount}'),
          _StatItem(label: '粉丝', value: '${user.followerCount}'),
          _StatItem(label: '关注', value: '${user.followingCount}'),
          _StatItem(label: '获赞', value: '${user.likeCount}'),
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
    final diagonal =
        sqrt(size.width * size.width + size.height * size.height);

    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: diagonal * 0.03,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: diagonal * 0.01),
        Text(
          label,
          style: TextStyle(
            fontSize: diagonal * 0.02,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

/* ===================== 积分进度 ===================== */

class _PointsCard extends StatelessWidget {
  final User user;

  const _PointsCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final nextLevelNeed = 500 - (user.points % 500);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Text('总积分', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 8),
          Text(
            '${user.points}',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: (user.points % 500) / 500,
            backgroundColor: Colors.grey.shade200,
            color: Colors.green,
          ),
          const SizedBox(height: 4),
          Text(
            '距离 Lv.${user.level + 1} 还需 $nextLevelNeed 积分',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

/* ===================== 菜单 ===================== */

class _MenuSection extends StatelessWidget {
  final User currentUser;
  final VoidCallback onUpdated;

  const _MenuSection({
    required this.currentUser,
    required this.onUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 5),
        _MenuItem(
          icon: Icons.emoji_events,
          title: '我的帖子',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => OtherUserProfilePage(currentUser.id),
              ),
            );
          },
        ),
        const SizedBox(height: 5),
        _MenuItem(icon: Icons.bookmark_border, title: '我的收藏'),
        const SizedBox(height: 5),
        _MenuItem(icon: Icons.verified_outlined, title: '达人认证'),
        const SizedBox(height: 5),
        _MenuItem(
          icon: Icons.settings_outlined,
          title: '设置',
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => EditProfilePage(
                  avatarUrl: currentUser.avatar ?? '',
                  nickname: currentUser.nickname ?? '',
                  bio: currentUser.bio ?? '',
                  gender: currentUser.gender,
                ),
              ),
            );
            onUpdated();
          },
        ),
        const SizedBox(height: 5),
        _MenuItem(
          icon: Icons.info_outline,
          title: '关于我们',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AboutPage()),
            );
          },
        ),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final diagonal =
        sqrt(size.width * size.width + size.height * size.height);

    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(
        title,
        style: TextStyle(
          fontSize: diagonal * 0.02,
          fontWeight: FontWeight.w400,
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

/* ===================== 退出登录 ===================== */

class _LogoutButton extends StatelessWidget {
  final VoidCallback onLogout;

  const _LogoutButton({required this.onLogout});

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
        onPressed: onLogout,
        child: Text(
          '退出登录',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(color: Colors.amber),
        ),
      ),
    );
  }
}