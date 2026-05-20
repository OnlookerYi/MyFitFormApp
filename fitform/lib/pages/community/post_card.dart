import 'package:flutter/material.dart';
import 'package:fitform/models/post.dart';
import 'package:fitform/widgets/common_image.dart';
import 'package:fitform/models/user.dart';

import 'package:video_player/video_player.dart';

class PostCard extends StatefulWidget {
  final Post post;
  final User author;
  final VoidCallback? onLike;
  final VoidCallback? onCollect;

  const PostCard({
    super.key,
    required this.post,
    required this.author,
    this.onLike,
    this.onCollect,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();

    if (widget.post.type == PostType.video &&
        widget.post.videoUrl != null &&
        widget.post.videoUrl!.isNotEmpty) {

      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.post.videoUrl!),
      );

      _controller!.initialize().then((_) {
        if (mounted) setState(() {});
      }).catchError((e) {
        debugPrint('🚨 视频初始化失败: $e');
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 用户信息
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: (widget.author.avatar != null &&
                          widget.author.avatar!.startsWith('http'))
                      ? NetworkImage(widget.author.avatar!)
                      : null,
                  child: (widget.author.avatar == null || widget.author.avatar!.isEmpty)
                      ? Text(
                          (widget.author.nickname?.isNotEmpty == true)
                              ? widget.author.nickname![0]
                              : widget.author.username,
                        )
                      : null,
                ),
                const SizedBox(width: 10),
                Text(
                  widget.author.nickname ?? '',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),

            const SizedBox(height: 10),

            /// 正文
            Text(widget.post.content),

            const SizedBox(height: 10),

            /// ✅ 根据类型渲染
            _buildMedia(),

            const SizedBox(height: 12),

            /// 操作栏
            Row(
              children: [
                _ActionItem(
                  icon: Icons.favorite_border,
                  activeIcon: Icons.favorite,
                  count: widget.post.likeCount,
                  active: widget.post.liked,
                  onTap: widget.onLike,
                ),
                const SizedBox(width: 20),
                _ActionItem(
                  icon: Icons.chat_bubble_outline,
                  count: widget.post.commentCount,
                  onTap: () {},
                ),
                const SizedBox(width: 20),
                _ActionItem(
                  icon: Icons.bookmark_border,
                  activeIcon: Icons.bookmark,
                  count: widget.post.collectCount,
                  active: widget.post.collected,
                  onTap: widget.onCollect,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMedia() {
    switch (widget.post.type) {
      case PostType.video:
        if (_controller == null || !_controller!.value.isInitialized) {
            return const SizedBox(
              height: 180,
              child: Center(child: CircularProgressIndicator()),
            );
        }

        return GestureDetector(
          onTap: () {
            if (_controller!.value.isPlaying) {
              _controller!.pause();
            } else {
              _controller!.play();
            }
          },
          child: AspectRatio(
            aspectRatio: _controller!.value.aspectRatio,
            child: Stack(
              alignment: Alignment.center,
              children: [
                VideoPlayer(_controller!),

                // ✅ 播放 / 暂停按钮
                if (!_controller!.value.isPlaying)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_arrow,
                      size: 64,
                      color: Colors.white,
                    ),
                  ),
              ],
            ),
          ),
        );

      case PostType.image:
      case PostType.analysis:
        if (widget.post.images.isEmpty) return const SizedBox.shrink();
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CommonImage(widget.post.images.first),
        );
    }
  }
}

class _ActionItem extends StatelessWidget {
  final IconData icon;
  final IconData? activeIcon;
  final int count;
  final bool active;
  final VoidCallback? onTap;

  const _ActionItem({
    required this.icon,
    this.activeIcon,
    required this.count,
    this.active = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            active ? (activeIcon ?? icon) : icon,
            size: 18,
            color: active ? Colors.red : Colors.grey,
          ),
          const SizedBox(width: 4),
          Text(count.toString()),
        ],
      ),
    );
  }
}