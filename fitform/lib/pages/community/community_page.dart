import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fitform/models/post.dart';
import 'publish_post_page.dart';
import 'package:fitform/services/post_service.dart';
import 'package:fitform/services/user_service.dart';
import 'post_detail_page.dart';
import 'post_card.dart';
import 'package:fitform/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitform/services/like_service.dart';
import 'package:fitform/services/collect_service.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => CommunityPageState();
}

class CommunityPageState extends State<CommunityPage> {
  final List<Post> posts = [];
  bool loading = true;
  int? currentUserId;
  final Map<int, User> authors = {};

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> refresh() async {
    await _loadPosts(); // ✅ 重新请求服务器
  }

  Future<void> _init() async {
    await _loadCurrentUser();
    await _loadPosts();
  }

  Future<void> _loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      currentUserId = prefs.getInt('userId');
    });
  }

  Future<void> _loadPosts() async {
    try {
      final list = await PostService.getPosts(currentUserId ?? 0);
      authors.clear();

      final ids = list.map((p) => p.authorId).toSet();
      for (final id in ids) {
        authors[id] = await UserService.getProfile(id);
      }

      if (mounted) {
        setState(() {
          posts
            ..clear()
            ..addAll(list);
          loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => loading = false);
    }
  }

  void _toggleLike(int postId) async {
    final index = posts.indexWhere((p) => p.id == postId);
    if (index == -1) return;

    final post = posts[index];

    try {
      if (post.liked) {
        await LikeService.unlike(currentUserId!, postId);
      } else {
        await LikeService.like(currentUserId!, postId);
      }

      final updatedPost = await PostService.getPost(postId);
      setState(() => posts[index] = updatedPost);
    } catch (e) {
      debugPrint('点赞失败: $e');
    }
  }

  void _toggleCollect(int postId) async {
    final index = posts.indexWhere((p) => p.id == postId);
    if (index == -1) return;

    final post = posts[index];

    try {
      if (post.collected) {
        await CollectService.uncollect(currentUserId!, postId);
      } else {
        await CollectService.collect(currentUserId!, postId);
      }

      final updatedPost = await PostService.getPost(postId);
      setState(() => posts[index] = updatedPost);
    } catch (e) {
      debugPrint('收藏失败: $e');
    }
  }

  Future<void> _deletePost(int index) async {
    final ok = await PostService.deletePost(posts[index].id);
    if (ok && mounted) setState(() => posts.removeAt(index));
  }

  void _refreshPost(int postId) async {
    final index = posts.indexWhere((p) => p.id == postId);
    if (index == -1) return;

    final updated = await PostService.getPost(postId);
    setState(() => posts[index] = updated);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final diagonal =
        sqrt(size.width * size.width + size.height * size.height);

    return Scaffold(
      appBar: AppBar(
        title: Text(
                '社区',
                style: TextStyle(         // ✅ 颜色
                  fontWeight: FontWeight.w600, // ✅ 粗细
                  fontSize: 24,                // ✅ 字号（可选）
                ),
              ),
        centerTitle: true,
        elevation: 1,
        backgroundColor: const Color(0xF00ED1E8),
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.push<Post>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PublishPostPage(),
                  ),
                );

                if (result != null) {
                  if (!authors.containsKey(result.authorId)) {
                    authors[result.authorId] =
                        await UserService.getProfile(result.authorId);
                  }
                  setState(() => posts.insert(0, result));
                }
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text('发布'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                textStyle: TextStyle(
                  fontSize: diagonal * 0.014,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
      body: loading || currentUserId == null
          ? const Center(child: CircularProgressIndicator())
          : posts.isEmpty
              ? const Center(
                  child: Text(
                    '暂无动态，快来发布第一条吧 📝',
                    style: TextStyle(fontSize: 15, color: Colors.grey),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  itemCount: posts.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) {
                    final post = posts[i];
                    final isAuthor = post.authorId == currentUserId;

                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PostDetailPage(
                              post,
                              onLike: () => _toggleLike(post.id),
                              onCollect: () => _toggleCollect(post.id),
                              onComment: () => _refreshPost(post.id),
                            ),
                          ),
                        );
                      },
                      child: Stack(
                        children: [
                          PostCard(
                            key: ValueKey(post.id),
                            post: post,
                            author: authors[post.authorId] ??
                                User(
                                  id: post.authorId,
                                  username: 'unknown',
                                  nickname: '未知用户',
                                  avatar: '',
                                  bio: '',
                                ),
                            preview: false,
                            onLike: () => _toggleLike(post.id),
                            onCollect: () => _toggleCollect(post.id),
                            enableAvatarTap: true,
                            showAvatar: true,
                          ),
                          if (isAuthor)
                            Positioned(
                              top: 6,
                              right: 6,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                ),
                                onPressed: () => _deletePost(i),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}