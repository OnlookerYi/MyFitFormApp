import 'dart:math';
import 'package:fitform/services/auth_service.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _userCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();

  String _userHint = '';
  Color _userColor = Colors.grey;
  String _pwdHint = '';
  Color _pwdColor = Colors.grey;

  bool _loading = false;

  @override
  void initState() {
    super.initState();

    _userCtrl.addListener(_validateUser);
    _pwdCtrl.addListener(_validatePassword);
  }

  void _validateUser() {
    final text = _userCtrl.text;
    if (text.length < 3) {
      _userHint = '用户名至少 3 位';
      _userColor = Colors.red;
    } else if (text.length > 12) {
      _userHint = '用户名最多 12 位';
      _userColor = Colors.red;
    } else {
      _userHint = '用户名可用';
      _userColor = Colors.green;
    }
    setState(() {});
  }

  void _validatePassword() {
    final pwd = _pwdCtrl.text;

    if (pwd.length < 8) {
      _pwdHint = '密码至少 8 位';
      _pwdColor = Colors.red;
    }else if (pwd.length > 16) {
      _pwdHint = '密码至多16位';
      _pwdColor = Colors.red;
    }else if (_strong(pwd)) {
      _pwdHint = '密码强度：强';
      _pwdColor = Colors.green;
    } else if (_medium(pwd)) {
      _pwdHint = '密码强度：中';
      _pwdColor = Colors.orange;
    } else {
      _pwdHint = '密码强度：弱';
      _pwdColor = Colors.red;
    }

    setState(() {});
  }

  bool _medium(String pwd) =>
      pwd.contains(RegExp(r'[A-Za-z]')) &&(
      pwd.contains(RegExp(r'[0-9]')) ||
      pwd.contains(RegExp(r'[!@#\$%^&*]'))
      );

  bool _strong(String pwd) =>
      pwd.contains(RegExp(r'[A-Za-z]')) &&
      pwd.contains(RegExp(r'[0-9]')) &&
      pwd.contains(RegExp(r'[!@#\$%^&*]'));

  
  Future<void> _handleRegister() async {
    final username = _userCtrl.text.trim();
    final password = _pwdCtrl.text;

    // 前端校验兜底
    if (username.length < 3 ||
        username.length > 12 ||
        password.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请正确填写用户名和密码')),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final result = await AuthService.register(username, password);

      if (!mounted) return;

      if (result["msg"] == "注册成功") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('注册成功，请登录')),
        );
        Navigator.pop(context); // 回到登录页
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result["msg"] ?? "注册失败")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("网络错误：$e")),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  
  @override
  void dispose() {
    _userCtrl.dispose();
    _pwdCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final size = MediaQuery.of(context).size;
    final diagonal = sqrt(size.width * size.width + size.height * size.height);

    return Scaffold(
      appBar: AppBar(title: const Text('注册')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              style: TextStyle(
                fontSize: diagonal * 0.02
              ),
              controller: _userCtrl,
              decoration: InputDecoration(
                labelText: '用户名',
                labelStyle: TextStyle(
                  fontSize: diagonal * 0.016,
                ),
                helperText: _userHint,
                helperStyle: TextStyle(color: _userColor, fontSize: diagonal * 0.012),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              style: TextStyle(
                fontSize: diagonal * 0.02,
              ),
              controller: _pwdCtrl,
              obscureText: true,
              decoration: InputDecoration(
                labelText: '密码',
                labelStyle: TextStyle(
                  fontSize: diagonal * 0.016
                ),
                helperText: _pwdHint,
                helperStyle: TextStyle(color: _pwdColor, fontSize: diagonal * 0.012),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _handleRegister,
                child: _loading
                    ? const CircularProgressIndicator()
                    : const Text('注册',)
              ),
            )
          ],
        ),
      ),
    );
  }
}