import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'user_service.dart';

class MediaPipeApi {
  static const String base = 'http://8.163.118.22';

  /// 1️⃣ 上传视频（✅ 补 user_id）
  static Future<String> analyzeVideo(File file, String action) async {
    final userId = await UserService.getCurrentUserId();

    if (userId == null) {
      throw Exception('未登录，无法分析');
    }

    final req = http.MultipartRequest(
      'POST',
      Uri.parse('$base/api/analyze'),
    );

    req.fields['user_id'] = userId.toString();
    req.fields['action'] = action;
    req.files.add(await http.MultipartFile.fromPath('video', file.path));

    final res = await req.send();
    final body = await res.stream.bytesToString();

    if (res.statusCode != 200) {
      throw Exception('分析失败：$body');
    }

    final data = jsonDecode(body);
    return data['task_id'];
  }

  /// 2️⃣ 轮询结果（✅ 不变）
  static Future<Map<String, dynamic>> pollResult(
    String taskId, {
    required void Function(String status) onStatus,
  }) async {
    final client = http.Client();
    final deadline = DateTime.now().add(const Duration(minutes: 2));

    try {
      while (DateTime.now().isBefore(deadline)) {
        final res = await client.get(
          Uri.parse('$base/api/analyze/result/$taskId'),
        );

        final data = jsonDecode(res.body);
        onStatus(data['status']);

        if (data['status'] == 'done') return data['data'];
        if (data['status'] == 'failed') throw Exception('分析失败');
        if (data['status'] == 'canceled') throw Exception('已取消');

        await Future.delayed(const Duration(seconds: 2));
      }

      throw Exception('分析超时');
    } finally {
      client.close();
    }
  }

  /// 3️⃣ 取消分析（✅ 不变）
  static Future<void> cancel(String taskId) async {
    final client = http.Client();
    try {
      await client.post(
        Uri.parse('$base/api/analyze/cancel'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'task_id': taskId}),
      );
    } finally {
      client.close();
    }
  }
}