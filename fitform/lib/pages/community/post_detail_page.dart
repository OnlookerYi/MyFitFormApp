import 'package:fitform/services/user_service.dart';
import 'package:fitform/services/comment_service.dart';
import 'package:flutter/material.dart';
import 'package:fitform/models/user.dart';
import 'package:fitform/models/post.dart';
import 'package:fitform/models/comment.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'post_card.dart';


class PostDetailPage extends StatefulWidget {
  final Post post;

  const PostDetailPage(this.post, {super.key});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  late List<Comment> _comments;
  Map<int, User> authors = {};

  final _controller = TextEditingController();

  late User currentUser;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');

      if (userId == null) {
        throw Exception('未登录');
      }

      currentUser = await UserService.getProfile(userId);

      final comments = await CommentService.getComments(widget.post.id);

      final userIds = {
        widget.post.authorId,
        ...comments.map((c) => c.userId),
      };

      for (final id in userIds) {
        authors[id] = await UserService.getProfile(id);
      }

      if (mounted) {
        setState(() {
          _comments = comments;
          loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载失败：$e')),
        );
      }
    }
  }

  Future<void> _addComment() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    try {
      final comment = await CommentService.addComment(
        postId: widget.post.id,
        userId: currentUser.id,
        content: text,
      );

      authors[currentUser.id] ??= currentUser;
      
      setState(() {
        _comments.insert(0, comment);
        _controller.clear();
      });
    } catch (e) {
      if(!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('评论失败：$e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('动态详情')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PostCard(
                        post: widget.post,
                        author: authors[widget.post.authorId] ??
                            User(
                              id: widget.post.authorId,
                              username: 'unknown',
                              nickname: '未知用户',
                              avatar: '',
                              bio: '',
                            ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        '评论',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ..._comments.map((c) {
                        final author = authors[c.userId] ?? 
                            User(
                              id: c.userId,
                              username: 'unknown',
                              nickname: '未知用户',
                              avatar: '',
                              bio: '',
                            );
                        return _CommentItem(c, author);
                      })
                    ],
                  ),
                ),
              ),

              /// 评论输入框
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          decoration: const InputDecoration(
                            hintText: '写下你的评论...',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: _addComment,
                        icon: const Icon(Icons.send),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
    );
  }
}

class _CommentItem extends StatelessWidget {
  final Comment comment;
  final User author;

  const _CommentItem(this.comment, this.author);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundImage: (author.avatar != null &&
                    author.avatar!.startsWith('http'))
                ? NetworkImage(author.avatar!)
                : null,
            child: (author.avatar == null || author.avatar!.isEmpty)
                ? Text(
                    (author.nickname?.isNotEmpty == true)
                        ? author.nickname![0]
                        : author.username[0],
                  )
                : null,
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  author.nickname ?? '',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(comment.content),
              ],
            ),
          ),
        ],
      ),
    );
  }
}