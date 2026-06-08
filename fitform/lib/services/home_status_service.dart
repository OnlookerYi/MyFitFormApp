import 'dart:convert';
import 'package:http/http.dart' as http;

class HomeStatus {
  final bool checkedIn;
  final int streak;
  final int duration;

  HomeStatus({
    required this.checkedIn,
    required this.streak,
    required this.duration,
  });

  factory HomeStatus.fromJson(Map<String, dynamic> json) {
    return HomeStatus(
      checkedIn: json['checked_in'] == true,
      streak: int.tryParse(json['streak'].toString()) ?? 0,
      duration: int.tryParse(json['duration'].toString()) ?? 0,
    );
  }
}

class HomeStatusService {
  static const String _base = 'http://8.163.118.22';

  static Future<HomeStatus> getStatus(int userId) async {
    final res = await http.get(
      Uri.parse('$_base/api/home/status?user_id=$userId'),
    );

    if (res.statusCode != 200) {
      throw Exception('获取首页状态失败');
    }

    return HomeStatus.fromJson(jsonDecode(res.body));
  }
}