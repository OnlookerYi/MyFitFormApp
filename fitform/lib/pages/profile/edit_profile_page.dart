import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fitform/services/user_service.dart'; // 改成你的路径

class EditProfilePage extends StatefulWidget {
  final String? avatarUrl;
  final String? nickname;
  final String? bio;
  final String? gender;

  const EditProfilePage({
    super.key,
    this.avatarUrl,
    this.nickname,
    this.bio,
    this.gender,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late String _gender;
  late String _avatarUrl;

  bool _uploading = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.nickname);
    _bioController = TextEditingController(text: widget.bio);
    _gender = widget.gender ?? '男';
    _avatarUrl = widget.avatarUrl ?? '';
  }

  /// ✅ 选择图片（不上传）
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      setState(() {
        _avatarUrl = file.path;
      });
    }
  }

  /// ✅ 上传头像
  Future<void> _uploadAvatar() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;

    setState(() => _uploading = true);

    try {
      final url = await UserService.uploadAvatar(File(file.path));
      setState(() {
        _avatarUrl = url;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('上传失败：$e')),
      );
    } finally {
      setState(() => _uploading = false);
    }
  }

  /// ✅ 保存用户信息
  Future<void> _save() async {
    print('🧪 save start');
    setState(() => _saving = true);

    try {
      await UserService.updateProfile(
        nickname: _nameController.text.trim(),
        bio: _bioController.text.trim(),
        gender: _gender,
        avatar: _avatarUrl,
      );
      print('🧪 save success');

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      print('❌ save failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('保存失败：$e')),
      );
    } finally {
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final diagonal =
        sqrt(size.width * size.width + size.height * size.height);

    return Scaffold(
      appBar: AppBar(
        title: const Text('编辑资料'),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: Text(
              '保存',
              style: TextStyle(
                color: Colors.green,
                fontSize: diagonal * 0.02,
              ),
            ),
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Column(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 48,
                    backgroundImage: _avatarUrl.startsWith('http')
                        ? NetworkImage(_avatarUrl)
                        : FileImage(File(_avatarUrl)),
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: _uploading ? null : _uploadAvatar,
                  icon: const Icon(Icons.upload),
                  label: Text(_uploading ? '上传中...' : '上传头像'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          TextField(
            controller: _nameController,
            maxLength: 12,
            decoration: const InputDecoration(labelText: '昵称'),
          ),

          const SizedBox(height: 20),

          DropdownButtonFormField<String>(
            value: _gender,
            items: const [
              DropdownMenuItem(value: '男', child: Text('男')),
              DropdownMenuItem(value: '女', child: Text('女')),
            ],
            onChanged: (v) => setState(() => _gender = v!),
            decoration: const InputDecoration(labelText: '性别'),
          ),

          const SizedBox(height: 20),

          TextField(
            controller: _bioController,
            maxLength: 100,
            maxLines: 3,
            decoration: const InputDecoration(labelText: '个人简介'),
          ),
        ],
      ),
    );
  }
}