import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthService {
  static const String baseUrl = "http://8.163.118.22/api";

  static Future<Map<String, dynamic>> register(
      String username, String password) async {
    final res = await http.post(
      Uri.parse("$baseUrl/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": username,
        "password": password,
      }),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> login(
      String username, String password) async {
    final res = await http.post(
      Uri.parse("$baseUrl/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": username,
        "password": password,
      }),
    );
    return jsonDecode(res.body);
  }
}