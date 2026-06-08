import 'package:flutter/material.dart';
import 'package:fitform/models/user.dart';
import 'package:fitform/models/post.dart';
import 'package:fitform/services/user_service.dart';
import 'package:fitform/services/post_service.dart';
import 'package:fitform/services/follow_service.dart';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import './post_detail_page.dart';
import 'post_card.dart';

class OtherUserProfilePage extends StatefulWidget {
  final int userId;

  const OtherUserProfilePage(this.userId, {super.key});

  @override
  State<OtherUserProfilePage> createState() => _OtherUserProfilePageState();
}

class _OtherUserProfilePageState extends State<OtherUserProfilePage> {
  User? user;
  bool isSelf = false;
  List<Post> posts = [];
  bool loading = true;
  bool isFollowing = false;

  @override
  void initState() {
    super.initState();
    _load();
    _checkSelf();
  }

  Future<void> _checkSelf() async {
    final prefs = await SharedPreferences.getInstance();
    final currentUserId = prefs.getInt('userId') ?? 0;

    setState(() {
      isSelf = currentUserId == widget.userId;
    });
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentUserId = prefs.getInt('userId');

      final u = await UserService.getProfile(widget.userId);
      final ps = await PostService.getPostsByUser(widget.userId);

      if (currentUserId != null) {
        isFollowing = await FollowService.isFollowing(
          currentUserId,
          widget.userId,
        );
      }

      if (mounted) {
        setState(() {
          user = u;
          posts = ps;
          loading = false;
        });
      }
    } catch (e, stack) {
      print('❌ OtherUserProfilePage error: $e');
      print(stack);
      if (mounted) setState(() => loading = false);
    }
  }

  void _toggleFollow() async {
    final prefs = await SharedPreferences.getInstance();
    final currentUserId = prefs.getInt('userId');
    if (currentUserId == null) return;

    if (isFollowing) {
      await FollowService.unfollow(currentUserId, widget.userId);
    } else {
      await FollowService.follow(currentUserId, widget.userId);
    }

    setState(() {
      isFollowing = !isFollowing;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading || user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(user!.nickname ?? '用户主页')),
      body: ListView(
        children: [
          _UserInfoSection(
            user: user!,
            isFollowing: isFollowing,
            onFollowTap: _toggleFollow,
            isSelf: isSelf,
          ),
          const SizedBox(height: 12),
          _StatsSection(user: user!),
          const SizedBox(height: 12),
          _buildPostList(),
        ],
      ),
    );
  }

  Widget _buildPostList() {
    if (posts.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text('TA 还没有发布过动态'),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: posts.length,
      itemBuilder: (_, i) => PostCard(
        post: posts[i],
        author: user!,
        preview: false,
        showAvatar: false,
        enableAvatarTap: false,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PostDetailPage(
                posts[i],
                onLike: () {},
                onCollect: () {},
                onComment: () {},
              ),
            ),
          );
        },
      ),
    );
  }
}

class _UserInfoSection extends StatelessWidget {
  final User user;
  final bool isFollowing;
  final bool isSelf;    
  final VoidCallback onFollowTap;

  const _UserInfoSection({
    required this.user,
    required this.isFollowing,
    required this.onFollowTap,
    required this.isSelf, 
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 48,
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
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Text(
                  '用户名:${user.username}',
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  user.bio?.isNotEmpty == true
                      ? user.bio!
                      : '暂无简介',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          if(!isSelf)
            ElevatedButton(
              onPressed: onFollowTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: isFollowing ? Colors.grey : Colors.blue,
              ),
              child: Text(isFollowing ? '已关注' : '关注'),
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
        Text(value,
            style: TextStyle(
                fontSize: diagonal * 0.03, fontWeight: FontWeight.w700)),
        SizedBox(height: diagonal * 0.01),
        Text(label,
            style: TextStyle(
                fontSize: diagonal * 0.02, fontWeight: FontWeight.w500)),
      ],
    );
  }
}