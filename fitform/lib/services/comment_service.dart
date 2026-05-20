import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/comment.dart';

class CommentService {
  static const base = 'http://8.163.118.22';

  /// ✅ 获取某条动态的评论（包含回复）
  static Future<List<Comment>> getComments(int postId) async {
    final res = await http.get(
      Uri.parse('$base/api/posts/$postId/comments'),
    );

    final jsonBody = jsonDecode(res.body);
    final list = jsonBody['data'] as List;

    return list.map((e) => Comment.fromJson(e)).toList();
  }

  /// ✅ 发表评论 / 回复
  static Future<Comment> addComment({
    required int postId,
    required int userId,
    required String content,
    int? parentId,
  }) async {
    final res = await http.post(
      Uri.parse('$base/api/comments'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'post_id': postId,
        'user_id': userId,
        'content': content,
        'parent_id': parentId,
      }),
    );

    final jsonBody = jsonDecode(res.body);
    return Comment.fromJson(jsonBody['data']);
  }
}