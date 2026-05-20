import 'dart:math';
import 'package:flutter/material.dart';
import 'edit_profile_page.dart';
import 'package:fitform/pages/main/splash_page.dart';
import 'package:fitform/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitform/services/user_service.dart';


class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? currentUser;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
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
        title: const Text('个人中心'),
        backgroundColor: Colors.greenAccent,
        foregroundColor: Colors.black,
        centerTitle: true,
      ),
      body: ListView(
        children: [
          _UserInfoSection(user: currentUser!),
          const SizedBox(height: 12),
          _StatsSection(user: currentUser!),
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
            MaterialPageRoute(builder: (_) => const SplashPage()),
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
  final User user;

  const _UserInfoSection({required this.user});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
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

        if (result != null) {
          // ✅ 回写后刷新
          // 你可以在这里重新 _loadUser()
        }
      },
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
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  user.bio ?? '这个人很懒，什么都没写～',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

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
          _StatItem(label: '帖子', value: '2'),
          _StatItem(label: '粉丝', value: '0'),
          _StatItem(label: '关注', value: '2'),
          _StatItem(label: '获赞', value: '6'),
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


