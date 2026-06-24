import 'dart:convert';
import 'package:http/http.dart' as http;

class AdminService {
  static const _base = 'http://8.163.118.22';

  /// ✅ 获取所有用户
  static Future<List<Map<String, dynamic>>> getAllUsers() async {
    final res = await http.get(
      Uri.parse('$_base/admin/users'),
    );

    if (res.statusCode != 200) {
      throw Exception('获取用户列表失败');
    }

    final body = jsonDecode(res.body);
    if (body['code'] != 200) {
      throw Exception(body['msg'] ?? '获取用户列表失败');
    }

    return List<Map<String, dynamic>>.from(body['data']);
  }

  /// ✅ 封禁用户
  static Future<void> banUser(int userId) async {
    final res = await http.post(
      Uri.parse('$_base/admin/users/$userId/ban'),
    );

    if (res.statusCode != 200) {
      throw Exception('封禁失败');
    }

    final body = jsonDecode(res.body);
    if (body['code'] != 200) {
      throw Exception(body['msg'] ?? '封禁失败');
    }
  }

  /// ✅ 解封用户（可选）
  static Future<void> unbanUser(int userId) async {
    final res = await http.post(
      Uri.parse('$_base/admin/users/$userId/unban'),
    );

    if (res.statusCode != 200) {
      throw Exception('解封失败');
    }

    final body = jsonDecode(res.body);
    if (body['code'] != 200) {
      throw Exception(body['msg'] ?? '解封失败');
    }
  }
  /// ✅ 获取举报列表
  static Future<List<Map<String, dynamic>>> getReports() async {
    final res = await http.get(
      Uri.parse('$_base/admin/reports'),
    );

    if (res.statusCode != 200) {
      throw Exception('获取举报列表失败');
    }

    final body = jsonDecode(res.body);
    if (body['code'] != 200) {
      throw Exception(body['msg'] ?? '获取举报列表失败');
    }

    return List<Map<String, dynamic>>.from(body['data']);
  }

  /// ✅ 处理举报
  static Future<void> resolveReport(int reportId) async {
    final res = await http.post(
      Uri.parse('$_base/admin/reports/$reportId/resolve'),
    );

    if (res.statusCode != 200) {
      throw Exception('处理失败');
    }

    final body = jsonDecode(res.body);
    if (body['code'] != 200) {
      throw Exception(body['msg'] ?? '处理失败');
    }
  }

  /// ✅ 忽略举报
  static Future<void> ignoreReport(int reportId) async {
    final res = await http.post(
      Uri.parse('$_base/admin/reports/$reportId/ignore'),
    );

    if (res.statusCode != 200) {
      throw Exception('忽略失败');
    }

    final body = jsonDecode(res.body);
    if (body['code'] != 200) {
      throw Exception(body['msg'] ?? '忽略失败');
    }
  }
}