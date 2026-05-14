import 'package:flutter/material.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userCtrl = TextEditingController();
    final pwdCtrl = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('注册')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: userCtrl,
              decoration: const InputDecoration(labelText: '用户名'),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: pwdCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: '密码'),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: 注册逻辑
                  print('注册：${userCtrl.text}');
                  Navigator.pop(context); // 返回登录页
                },
                child: const Text('注册'),
              ),
            )
          ],
        ),
      ),
    );
  }
}