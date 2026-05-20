import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fitform/models/post.dart';
import 'publish_post_page.dart';
import 'package:fitform/services/post_service.dart';
import 'package:fitform/services/user_service.dart';
import 'post_detail_page.dart';
import 'post_card.dart';
import 'package:fitform/models/user.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  final List<Post> posts = [];
  bool loading = true;

  final Map<int, User> authors = {};

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    try {
      final list = await PostService.getPosts();

      authors.clear();
      
      final userIds = list.map((p) => p.authorId).toSet();

      for (final id in userIds) {
        authors[id] = await UserService.getProfile(id);
      }

      if (mounted) {
        setState(() {
          posts.clear();
          posts.addAll(list);
          loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => loading = false);
    }
  }

  void _toggleLike(int index) {
    setState(() {
      final p = posts[index];
      p.liked = !p.liked;
      p.likeCount += p.liked ? 1 : -1;
    });
  }

  void _toggleCollect(int index) {
    setState(() {
      final p = posts[index];
      p.collected = !p.collected;
      p.collectCount += p.collected ? 1 : -1;
    });
  }

  @override
  Widget build(BuildContext context) {

    final size = MediaQuery.of(context).size;
    final diagonal = sqrt(size.width * size.width + size.height * size.height);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('社区'),
          bottom: const TabBar(
            tabs: [
              Tab(text: '推荐'),
              Tab(text: '热门'),
              Tab(text: '关注'),
            ],
          ),

          actions: [
            TextButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PublishPostPage(),
                  ),
                );

                if (result != null) {
                  _loadPosts();
                }

                if (result is Post) {
                  setState(() {
                    posts.insert(0, result);
                  });
                }
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                alignment: Alignment.center, // ✅ 文字居中
              ),
              child: Text(
                '发布',
                style: TextStyle(
                  fontSize: diagonal * 0.015,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),

        body: TabBarView(
          children: [
            ListView.builder(
              itemCount: posts.length,
              itemBuilder: (_, i) => GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PostDetailPage(posts[i]),
                    ),
                  );
                },
                child: PostCard(
                  post: posts[i],
                  author: authors[posts[i].authorId] ??
                      User(
                        id: posts[i].authorId,
                        username: 'unknown',
                        nickname: '未知用户',
                        avatar: '',
                        bio: '',
                      ),
                  onLike: () => _toggleLike(i),
                  onCollect: () => _toggleCollect(i),
                ),
              ),
            ),
            const Center(child: Text('热门')),
            const Center(child: Text('关注')),
          ],
        ),
      ),
    );
  }
}