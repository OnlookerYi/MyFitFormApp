import 'package:http/http.dart' as http;
import 'dart:convert';

class CollectService {
  static const base = 'http://8.163.118.22';

  static Future<bool> collect(int userId, int postId) async {
    final res = await http.post(
      Uri.parse('$base/api/collect'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'post_id': postId,
      }),
    );
    return res.statusCode == 200;
  }

  static Future<bool> uncollect(int userId, int postId) async {
    final res = await http.post(
      Uri.parse('$base/api/uncollect'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'post_id': postId,
      }),
    );
    return res.statusCode == 200;
  }
}
