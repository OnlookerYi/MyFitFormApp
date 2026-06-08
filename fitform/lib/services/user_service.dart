import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class UserService {
  static const base = 'http://8.163.118.22';
  static const _keyUserId = 'userId';

  /// ✅ 获取用户信息
  static Future<User> getProfile(int userId) async {
    final res = await http.get(
      Uri.parse('$base/api/users/$userId'),
    );


    if (res.statusCode != 200) {
      throw Exception('获取用户信息失败');
    }

    final body = jsonDecode(res.body);

    if (body['code'] != 200) {
      throw Exception(body['msg'] ?? '获取用户信息失败');
    }

    return User.fromJson(body['data']);
  }

  /// ✅ 获取用户统计
  static Future<Map<String, dynamic>> getUserStats(int userId) async {
    final res = await http.get(
      Uri.parse('$base/api/users/$userId/stats'),
    );

    if (res.statusCode != 200) {
      throw Exception('获取用户统计失败');
    }

    final body = jsonDecode(res.body);

    if (body['code'] != 200) {
      throw Exception(body['msg'] ?? '获取用户统计失败');
    }

    return Map<String, dynamic>.from(body['data']);
  }

  static Future<String> uploadAvatar(File file) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$base/api/upload/avatar'),
    );
    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    final res = await request.send();
    final body = await res.stream.bytesToString();

    print('📦 uploadAvatar status=${res.statusCode}');
    print('📦 uploadAvatar body=$body');

    if (res.statusCode != 200) {
      throw Exception('上传失败：$body');
    }

    final json = jsonDecode(body);

    return json['data']['url'];
  }

  static Future<void> updateProfile({
    required String nickname,
    required String bio,
    required String gender,
    required String avatar,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');

    await http.put(
      Uri.parse('$base/api/user/profile'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'nickname': nickname,
        'bio': bio,
        'gender': gender,
        'avatar': avatar,
      }),
    );
  }
  /// ✅ 拿后端 user_id
  static Future<int?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyUserId);
  }

  /// ✅ 登录后保存（后端给的）
  static Future<void> saveUserId(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyUserId, userId);
  }

  /// ✅ 退出登录
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

}