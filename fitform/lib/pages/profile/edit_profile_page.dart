import 'dart:math';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProfilePage extends StatefulWidget {
  final String avatarUrl;
  final String nickname;
  final String bio;
  final String gender;

  const EditProfilePage({
    super.key,
    required this.avatarUrl,
    required this.nickname,
    required this.bio,
    required this.gender,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late String _gender;
  late String _avatarUrl;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.nickname);
    _bioController = TextEditingController(text: widget.bio);
    _gender = widget.gender;
    _avatarUrl = widget.avatarUrl;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      setState(() {
        _avatarUrl = file.path;
      });
    }
  }

  void _save() {
    Navigator.pop(context, {
      'avatar': _avatarUrl,
      'nickname': _nameController.text,
      'bio': _bioController.text,
      'gender': _gender,
    });
  }

  @override
  Widget build(BuildContext context) {

    final size = MediaQuery.of(context).size;
    final diagonal = sqrt(size.width * size.width + size.height * size.height);

    return Scaffold(
      appBar: AppBar(
        title: const Text('编辑资料'),
        actions: [
          TextButton(
            onPressed: _save,
            child: Text('保存', style: TextStyle(color: Colors.green, fontSize: diagonal * 0.02)),
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 48,
                backgroundImage: _avatarUrl.startsWith('http')
                    ? NetworkImage(_avatarUrl)
                    : AssetImage(_avatarUrl),
              ),
            ),
          ),
          const SizedBox(height: 30),
          TextField(
            controller: _nameController,
            style: TextStyle(
              fontSize: diagonal * 0.02,
              fontWeight: FontWeight.w700,
            ),
            maxLength: 12,
            decoration: InputDecoration(
              labelText: '昵称',
              labelStyle: TextStyle(fontSize: diagonal * 0.025),
            ),
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            initialValue: _gender,
            items: [
              DropdownMenuItem(value: '男', child: Text('男', style: TextStyle(fontSize: diagonal * 0.01))),
              DropdownMenuItem(value: '女', child: Text('女', style: TextStyle(fontSize: diagonal * 0.01))),
            ],
            onChanged: (v) => setState(() => _gender = v!),
            decoration: InputDecoration(
              labelText: '性别',
              labelStyle: TextStyle(fontSize: diagonal * 0.025),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _bioController,
            style: TextStyle(
              fontSize: diagonal * 0.015,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 3,
            maxLength: 100,
            decoration: InputDecoration(
              labelText: '个人简介',
              labelStyle: TextStyle(fontSize: diagonal * 0.025),
            ),
          ),
        ],
      ),
    );
  }
}