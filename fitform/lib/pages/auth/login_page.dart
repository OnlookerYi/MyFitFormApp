import 'dart:math';
import 'package:fitform/services/auth_service.dart';
import 'package:fitform/widgets/common/app_titletext.dart';
import 'package:fitform/widgets/common/app_textfield.dart';
import 'package:fitform/widgets/common/app_button.dart';
import 'package:flutter/material.dart';
import '../main/main_page.dart';
import 'register_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitform/pages/admin/admin_console_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final usernameCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  bool isLoading = false;

  Future<void> handleLogin() async {
    final username = usernameCtrl.text.trim();
    final password = passwordCtrl.text;

    if (username.isEmpty || password.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入用户名和密码')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final result = await AuthService.login(username, password);

      if (!mounted) return;

      if (result["code"] == 200) {
        final user = result["data"];
        final banned = user["banned"] == true || user["banned"] == 1; 

        if (banned) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('该账号已被封禁，无法登录'),
            ),
          );
          setState(() => isLoading = false);
          return; // ❌ 不进入主页
        }
        final userId = user["id"];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('userId', userId);

        if (!mounted) return;

        Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainPage()),
          (route) => false,
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result["msg"] ?? "登录失败")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("网络错误：$e")),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<bool> _showAdminLoginDialog(BuildContext context) async {
    final adminUserCtrl = TextEditingController();
    final adminPassCtrl = TextEditingController();

    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            title: const Text('管理员登录'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: adminUserCtrl,
                  decoration: const InputDecoration(
                    labelText: '管理员账号',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: adminPassCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: '管理员密码',
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('取消'),
              ),
              ElevatedButton(
                onPressed: () {
                  final user = adminUserCtrl.text.trim();
                  final pass = adminPassCtrl.text;

                  if (user == 'admin' && pass == 'admin123') {
                    Navigator.pop(context, true);
                  } else {
                    Navigator.pop(context, false);
                  }
                },
                child: const Text('登录'),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final diagonal =
        sqrt(size.width * size.width + size.height * size.height);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Align(
                alignment: Alignment.center,
                child: Text(
                  'Welcome to Fitform',
                  style: TextStyle(
                    fontSize: diagonal * 0.05,
                    fontWeight: FontWeight.w700,
                    color: const Color.fromARGB(255, 251, 7, 255),
                  ),
                ),
              ),
              const SizedBox(height: 60),
              TitleText(
                '请输入账号和密码',
                style: TitleTextStyle.titleMedium,
              ),
              AppTextField(
                label: '用户名',
                controller: usernameCtrl,
                maxLength: 12,
              ),
              const SizedBox(height: 20),
              AppTextField(
                label: '密码',
                controller: passwordCtrl,
                obscureText: true,
                maxLength: 16,
              ),
              const SizedBox(height: 30),

              /// ✅ 登录按钮
              PrimaryButton(
                text: isLoading ? '登录中...' : '登录',
                onPressed: isLoading ? null : handleLogin,
              ),

              const Spacer(),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('没有账号？'),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true).push(
                        MaterialPageRoute(
                          builder: (_) => const RegisterPage(),
                        ),
                      );
                    },
                    child: const Text('去注册'),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Center(
                child: TextButton(
                  onPressed: () async {
                    final ok = await _showAdminLoginDialog(context);
                    if (ok && context.mounted) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const AdminPage(),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('管理员账号或密码错误')),
                      );
                    }
                  },
                  child: Text(
                    '管理员入口',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: Colors.redAccent,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}