import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/post.dart';

class PostService {
  static const base = 'http://8.163.118.22';

  static Future<List<Post>> getPosts() async {
    final res = await http.get(
      Uri.parse('$base/api/posts'),
    );

    if (res.statusCode != 200) {
      throw Exception('获取帖子失败');
    }

    final body = jsonDecode(res.body);
    if (body['data'] == null || body['data'] is! List) {
      return [];
    }

    return (body['data'] as List)
        .map((e) => Post.fromJson(e))
        .toList();
  }

  static Future<Post> publishPost({
    required int authorId,
    required String content,
    required PostType type,
    List<String> images = const [],
    String? videoUrl,
    int? analysisId,
  }) async {
    final res = await http.post(
      Uri.parse('$base/api/posts'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'author_id': authorId,
        'content': content,
        'type': type.name,
        'images': images,
        'video_url': videoUrl,
        'analysis_id': analysisId,
      }),
    );

    if (res.statusCode != 200) {
      throw Exception('发布失败');
    }
    
    final json = jsonDecode(res.body);
    return Post.fromJson(json['data']);
  }
}

