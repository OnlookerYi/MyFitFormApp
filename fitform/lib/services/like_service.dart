import 'dart:convert';
import 'package:http/http.dart' as http;

class LikeService {
  static Future<bool> like(int userId, int postId) async {
    final res = await http.post(
      Uri.parse('http://8.163.118.22/api/like'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'post_id': postId,
      }),
    );
    return res.statusCode == 200;
  }

  static Future<bool> unlike(int userId, int postId) async {
    final res = await http.post(
      Uri.parse('http://8.163.118.22/api/unlike'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'post_id': postId,
      }),
    );
    return res.statusCode == 200;
  }
}