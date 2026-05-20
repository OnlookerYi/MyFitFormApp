class Comment {
  final int id;
  final int postId;
  final int userId;

  /// 回复谁（null = 一级评论）
  final int? parentId;

  final String content;
  final String createdAt;

  int likeCount;
  bool liked;

  Comment({
    required this.id,
    required this.postId,
    required this.userId,
    this.parentId,
    required this.content,
    required this.createdAt,
    this.likeCount = 0,
    this.liked = false,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      postId: json['post_id'],
      userId: json['user_id'],
      parentId: json['parent_id'],
      content: json['content'] ?? '',
      createdAt: json['created_at'] ?? '',
      likeCount: json['like_count'] ?? 0,
      liked: json['liked'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'post_id': postId,
        'user_id': userId,
        'parent_id': parentId,
        'content': content,
        'created_at': createdAt,
        'like_count': likeCount,
        'liked': liked,
      };
}