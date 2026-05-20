class User {
  final int id;
  final String username;
  final String? nickname;
  final String? avatar;
  final String? bio;
  final String gender;      // ✅ 补回

  final bool isExpert;      // 是否是达人
  final int points;         // 积分

  User({
    required this.id,
    required this.username,
    this.nickname,
    this.avatar,
    this.bio,
    this.gender = 'unknown', // ✅ 默认值
    this.isExpert = false,
    this.points = 0,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'] ?? '',
      nickname: json['nickname']?.toString().isNotEmpty == true
          ? json['nickname']
          : json['username'] ?? '未知用户',
      avatar: json['avatar'],
      bio: json['bio'],
      gender: json['gender'] ?? 'unknown',
      isExpert: json['is_expert'] == 1 || json['is_expert'] == true,
      points: json['points'] ?? 0,
    );
  }
  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'nickname': nickname,
        'avatar': avatar,
        'bio': bio,
        'gender': gender,
        'is_expert': isExpert,
        'points': points,
      };
}