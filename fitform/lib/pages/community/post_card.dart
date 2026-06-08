import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:fitform/models/post.dart';
import 'package:fitform/models/user.dart';
import './image_preview_page.dart';
import './other_user_profile_page.dart';

class PostCard extends StatefulWidget {
  final Post post;
  final User author;
  final bool preview; // ✅ true = 详情页
  final VoidCallback? onLike;
  final VoidCallback? onCollect;
  final VoidCallback? onTap;

  final bool showAvatar;        // ✅ 是否显示头像区
  final bool enableAvatarTap;   // ✅ 头像是否可点

  const PostCard({
    super.key,
    required this.post,
    required this.author,
    this.preview = false,
    this.showAvatar = true,
    this.enableAvatarTap = true,
    this.onLike,
    this.onCollect,
    this.onTap,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard>
    with AutomaticKeepAliveClientMixin {
  VideoPlayerController? _controller;

  @override
  bool get wantKeepAlive => !widget.preview;

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
        if (mounted) {
          if (widget.preview) {
            _controller!.pause();
            _controller!.setVolume(1.0);
          } else {
            _controller!.setVolume(0);
            _controller!.play();
          }
          setState(() {});
        }
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
    super.build(context);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// ✅ 头像区（可控制显示 & 点击）
              if (widget.showAvatar)
                Row(
                  children: [
                    GestureDetector(
                      onTap: widget.enableAvatarTap
                          ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      OtherUserProfilePage(widget.author.id),
                                ),
                              );
                            }
                          : null,
                      child: CircleAvatar(
                        radius: 23,
                        backgroundImage: (widget.author.avatar != null &&
                                widget.author.avatar!.startsWith('http'))
                            ? NetworkImage(widget.author.avatar!)
                            : null,
                        child: (widget.author.avatar == null ||
                                widget.author.avatar!.isEmpty)
                            ? Text(
                                (widget.author.nickname?.isNotEmpty == true)
                                    ? widget.author.nickname![0]
                                    : widget.author.username,
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: widget.enableAvatarTap
                          ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      OtherUserProfilePage(widget.author.id),
                                ),
                              );
                            }
                          : null,
                      child: Text(
                        widget.author.nickname ?? '',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 10),
              Text(widget.post.content),
              const SizedBox(height: 10),

              _buildMedia(),

              const SizedBox(height: 12),

              /// ✅ 操作栏
              Row(
                children: [
                  _ActionItem(
                    icon: Icons.favorite_border,
                    activeIcon: Icons.favorite,
                    count: widget.post.likeCount,
                    active: widget.post.liked,
                    activeColor: Colors.red,
                    onTap: widget.onLike,
                  ),
                  const SizedBox(width: 28),
                  _ActionItem(
                    icon: Icons.chat_bubble_outline,
                    count: widget.post.commentCount,
                    onTap: () {},
                  ),
                  const SizedBox(width: 28),
                  _ActionItem(
                    icon: Icons.star_border,
                    activeIcon: Icons.star,
                    count: widget.post.collectCount,
                    active: widget.post.collected,
                    activeColor: Colors.amber,
                    onTap: widget.onCollect,
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMedia() {
    switch (widget.post.type) {
      case PostType.video:
        if (_controller == null || !_controller!.value.isInitialized) {
          return const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: widget.preview
              ? AspectRatio(
                  aspectRatio: _controller!.value.aspectRatio,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      VideoPlayer(_controller!),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _controller!.value.isPlaying
                                ? _controller!.pause()
                                : _controller!.play();
                          });
                        },
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.black45,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(12),
                          child: Icon(
                            _controller!.value.isPlaying
                                ? Icons.pause
                                : Icons.play_arrow,
                            size: 36,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : SizedBox(
                  height: 200,
                  child: AspectRatio(
                    aspectRatio: _controller!.value.aspectRatio,
                    child: VideoPlayer(_controller!),
                  ),
                )
              );

      case PostType.image:
      case PostType.analysis:
        if (widget.post.images.isEmpty) return const SizedBox.shrink();

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ImagePreviewPage(
                  widget.post.images.first,
                ),
              ),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: widget.preview
                ? Image.network(
                    widget.post.images.first,
                    fit: BoxFit.contain,
                  )
                : ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 200),
                    child: Image.network(
                      widget.post.images.first,
                      fit: BoxFit.cover,
                      cacheWidth: 600,
                      cacheHeight: 400,
                    ),
                  ),
          ),
        );
    }
  }
}

class _ActionItem extends StatelessWidget {
  final IconData icon;
  final IconData? activeIcon;
  final int count;
  final bool active;
  final Color activeColor;
  final VoidCallback? onTap;

  const _ActionItem({
    required this.icon,
    this.activeIcon,
    required this.count,
    this.active = false,
    this.activeColor = Colors.red,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          children: [
            Icon(
              active ? (activeIcon ?? icon) : icon,
              size: 22,
              color: active ? activeColor : Colors.grey[700],
            ),
            const SizedBox(width: 6),
            Text(
              count.toString(),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}