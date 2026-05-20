import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class UploadService {
  /// ✅ 和你其他 Service 保持一致
  static const String base = 'http://8.163.118.22';

  static Future<String> upload(File file) async {
    final req = http.MultipartRequest(
      'POST',
      Uri.parse('$base/api/upload'),
    );

    req.files.add(await http.MultipartFile.fromPath('file', file.path));

    final res = await req.send();
    final body = jsonDecode(await res.stream.bytesToString());

    if (res.statusCode != 200) {
      throw Exception('上传失败：${res.statusCode}');
    }

    final data = body['data'];

    // ✅ 优先 video_url，兜底 url
    debugPrint(data['video_url']);
    debugPrint(data['url']);
    return data['video_url'] ?? data['url'];
  }
}