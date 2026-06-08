import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/post.dart';
import 'package:shared_preferences/shared_preferences.dart';
class PostService {
  static const base = 'http://8.163.118.22';

  static Future<Post> getPost(int postId) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');

    print('📤 getPost postId=$postId userId=$userId');

    final res = await http.get(
      Uri.parse('$base/api/posts/$postId'),
      headers: {
        'X-User-Id': userId.toString(),
      },
    );

    if (res.statusCode != 200) {
      throw Exception('获取帖子失败');
    }

    final body = jsonDecode(res.body);
    return Post.fromJson(body['data']);
  }

  static Future<List<Post>> getPosts(int userId) async {
    final res = await http.get(
      Uri.parse('$base/api/posts'),
      headers: {
        'X-User-Id': userId.toString(),
      },
    );

    if (res.statusCode != 200) throw Exception('获取帖子失败');

    final body = jsonDecode(res.body);
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

    print('📤 请求后端，authorId = $authorId');

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
    print('📥 后端返回：${res.body}');

    if (res.statusCode != 200) {
      throw Exception('发布失败');
    }
    
    final json = jsonDecode(res.body);
    return Post.fromJson(json['data']);
  }

  static Future<bool> deletePost(int postId) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    print('🧪 deletePost: postId=$postId, userId=$userId');

    final res = await http.delete(
      Uri.parse('$base/api/posts/$postId'),
      headers: {
        'Content-Type': 'application/json',
        'X-User-Id': userId.toString(),
      },
    );

    print('📬 statusCode=${res.statusCode}, body=${res.body}');
    return res.statusCode == 200;
  }

  static Future<List<Post>> getPostsByUser(int userId) async {
    final res = await http.get(
      Uri.parse('$base/api/users/$userId/posts'),
    );
    final body = jsonDecode(res.body);
    return (body['data'] as List)
        .map((e) => Post.fromJson(e))
        .toList();
  }
  
}

