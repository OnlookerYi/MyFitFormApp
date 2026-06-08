import 'dart:convert';

class AnalysisHistoryItem {
  final int id;
  final String exercise;
  final int score;
  final int reps;
  final String? summary;
  final DateTime createdAt;

  /// ✅ 对外永远暴露 Map
  final Map<String, dynamic> detail;

  /// ✅ 内部可以接 String / Map
  AnalysisHistoryItem({
    required this.id,
    required this.exercise,
    required this.score,
    required this.reps,
    required this.summary,
    required this.createdAt,
    required dynamic detailJson,
  }) : detail = _parseDetail(detailJson);

  static Map<String, dynamic> _parseDetail(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      return raw;
    }
    if (raw is String) {
      try {
        return jsonDecode(raw);
      } catch (_) {
        return {};
      }
    }
    return {};
  }


  factory AnalysisHistoryItem.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic v) {
      if (v is int) return v;
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }
    
    DateTime parseCreatedAt(dynamic v) {
      if (v == null) return DateTime.now();

      final str = v.toString();

      // ✅ 兼容 MySQL 常见格式
      try {
        return DateTime.parse(str);
      } catch (_) {}

      try {
        return DateTime.parse(str.replaceFirst(' ', 'T'));
      } catch (_) {}

      return DateTime.now();
    }

    return AnalysisHistoryItem(
      id: parseInt(json['id']),
      exercise: json['exercise'].toString(),
      score: parseInt(json['score']),
      reps: parseInt(json['reps']),
      summary: json['summary']?.toString(),
      createdAt: parseCreatedAt(json['created_at']),
      detailJson: json['detail_json'],
    );
  }
}