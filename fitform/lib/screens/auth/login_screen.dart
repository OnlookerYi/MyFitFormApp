import 'package:fitform/widgets/common/app_titletext.dart';
import 'package:fitform/widgets/common/app_textfield.dart';
import 'package:fitform/widgets/common/app_button.dart';
import 'package:flutter/material.dart';
import '../main/main_screen.dart';
import 'register_screen.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});


  @override
  Widget build(BuildContext context) {
    final usernameCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA) ,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Align(
                alignment: Alignment.center,
                child: TitleText(
                  'Welcome to Fitform',
                  style: TitleTextStyle.titleLarge,
                ),
              ),
              const SizedBox(height: 60),
              
              const SizedBox(height: 10),

              TitleText(
                '请输入账号和密码',
                style: TitleTextStyle.titleMedium,
              ),
              /// 用户名
              AppTextField(
                label: '用户名',
                controller: usernameCtrl,
                maxLength: 12,
              ),
              const SizedBox(height: 20),

              /// 密码
              AppTextField(
                label: '密码',
                controller: passwordCtrl,
                obscureText: true,
                maxLength: 16,
              ),
              const SizedBox(height: 30),

              /// 登录按钮
              PrimaryButton(
                text: '登录',
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute(
                      builder: (_) => MainPage(),
                    ),
                  );
                },
              ),

              const Spacer(),

              /// 去注册
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('没有账号？'),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => const RegisterPage(),
                        ),
                      );
                    },
                    child: const Text('去注册'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}