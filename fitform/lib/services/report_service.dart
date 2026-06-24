import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ReportService {
  static const _base = 'http://8.163.118.22';

  static Future<void> reportUser({
    required int targetUserId,
    required String reason,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final reporterId = prefs.getInt('userId');

    if (reporterId == null) {
      throw Exception('未登录');
    }

    final res = await http.post(
      Uri.parse('$_base/report'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'reporter_id': reporterId,
        'target_type': 'user',
        'target_id': targetUserId,
        'reason': reason,
      }),
    );

    if (res.statusCode != 200) {
      throw Exception('举报失败');
    }

    final body = jsonDecode(res.body);
    if (body['code'] != 200) {
      throw Exception(body['msg'] ?? '举报失败');
    }
  }
}