import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/user.dart';

class UserService {
  static const base = 'http://8.163.118.22';

  static Future<User> getProfile(int userId) async {
  final res = await http.get(
    Uri.parse('$base/api/users/$userId'),
  );

  if (res.statusCode != 200) {
    throw Exception('获取用户信息失败');
  }

  return User.fromJson(jsonDecode(res.body)['data']);
  }
}