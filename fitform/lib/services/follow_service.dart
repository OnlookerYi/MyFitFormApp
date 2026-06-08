import 'package:http/http.dart' as http;
import 'dart:convert';

class FollowService {
  static const String _base = 'http://8.163.118.22';

  /// ✅ 关注
  static Future<bool> follow(int followerId, int followedId) async {
    final res = await http.post(
      Uri.parse('$_base/api/follow'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'follower_id': followerId,
        'followed_id': followedId,
      }),
    );
    return res.statusCode == 200;
  }

  /// ✅ 取消关注
  static Future<bool> unfollow(int followerId, int followedId) async {
    final res = await http.post(
      Uri.parse('$_base/api/unfollow'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'follower_id': followerId,
        'followed_id': followedId,
      }),
    );
    return res.statusCode == 200;
  }

  /// ✅ 是否关注（必须和后端 route 对得上）
  static Future<bool> isFollowing(int followerId, int followedId) async {
    final res = await http.get(
      Uri.parse(
        '$_base/api/follow/is_following'
        '?follower_id=$followerId'
        '&followed_id=$followedId',
      ),
    );

    if (res.statusCode != 200) return false;

    final body = jsonDecode(res.body);
    return body['is_following'] == true;
  }
}