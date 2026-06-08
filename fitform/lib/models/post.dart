import 'dart:convert';

enum PostType { image, video, analysis }

class Post {
  final int id;
  final int authorId;
  final String content;
  final PostType type;

  final List<String> images;
  final String? videoUrl;
  final int? analysisId;

  int likeCount;
  int commentCount;
  int collectCount;
  bool liked;
  bool collected;
  final String createdAt;

  Post({
    required this.id,
    required this.authorId,
    required this.content,
    required this.type,
    this.images = const [],
    this.videoUrl,
    this.analysisId,
    this.likeCount = 0,
    this.commentCount = 0,
    this.collectCount = 0,
    this.liked = false,
    this.collected = false,
    this.createdAt = '',
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    print('🧩 Post.fromJson author_id = ${json['author_id']}');
    List<String> parseImages(dynamic images) {
      if (images == null) return [];
      if (images is List) return List<String>.from(images);
      if (images is String) {
        if (images.isEmpty) return [];
        try {
          final decoded = jsonDecode(images);
          if (decoded is List) return List<String>.from(decoded);
        } catch (_) {}
      }
      return [];
    }

    return Post(
      id: json['id'],
      authorId: json['author_id'],
      content: json['content'] ?? '',
      type: _parseType(json['type']),
      images: parseImages(json['images']),
      videoUrl: json['video_url'] ?? json['url'],
      analysisId: json['analysis_id'] == null ? null : json['analysis_id'] as int?,
      likeCount: json['like_count'] ?? 0,
      commentCount: json['comment_count'] ?? 0,
      collectCount: json['collect_count'] ?? 0,
      liked: json['liked'] == 1 || json['liked'] == true,
      collected: json['collected'] == 1 || json['collected'] == true,
      createdAt: json['created_at'] ?? '',
    );
  }

  static PostType _parseType(String? t) {
    switch (t) {
      case 'video':
        return PostType.video;
      case 'analysis':
        return PostType.analysis;
      default:
        return PostType.image;
    }
  }
}