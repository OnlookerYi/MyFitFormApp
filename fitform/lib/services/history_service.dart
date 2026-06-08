import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/analysis_history_item.dart';

class HistoryApi {
  static const _base = 'http://8.163.118.22';

  /// ✅ 查询当前用户的历史
  static Future<List<AnalysisHistoryItem>> fetchHistory(int userId) async {
    final res = await http.get(
      Uri.parse('$_base/api/analysis/history?user_id=$userId'),
    );
    print('📦 statusCode = ${res.statusCode}');
    print('📦 body = ${res.body}');
    if (res.statusCode != 200) {
      throw Exception('获取历史失败');
    }

    final data = jsonDecode(res.body);
    print('📦 decoded type = ${data.runtimeType}');
    print('📦 first item = ${data.isNotEmpty ? data.first : 'empty'}');
    return data
        .map<AnalysisHistoryItem>((e) => AnalysisHistoryItem.fromJson(e))
        .toList();
  }
}