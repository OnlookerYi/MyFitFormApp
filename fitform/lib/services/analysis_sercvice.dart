import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/workout_analysis.dart';

class AnalysisService {
  static const base = 'http://8.163.118.22';

  /// ✅ 创建分析记录
  static Future<int> createAnalysis(WorkoutAnalysis analysis) async {
    final res = await http.post(
      Uri.parse('$base/api/analysis'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(analysis.toJson()),
    );

    final json = jsonDecode(res.body);
    return json['data']['id'];
  }

  /// ✅ 获取某个用户的分析记录
  static Future<List<WorkoutAnalysis>> getUserAnalysis(int userId) async {
    final res = await http.get(
      Uri.parse('$base/api/users/$userId/analysis'),
    );

    final jsonBody = jsonDecode(res.body);
    final list = jsonBody['data'] as List;

    return list.map((e) => WorkoutAnalysis.fromJson(e)).toList();
  }
}