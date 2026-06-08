class User {
  final int id;
  final String username;
  final String? nickname;
  final String? avatar;
  final String? bio;
  final String? gender;

  final int points;
  final int workouts;
  final int streak;
  final DateTime? lastWorkoutAt;
  final bool isExpert;

  /// ✅ 社区统计
  final int postCount;
  final int followerCount;
  final int followingCount;
  final int likeCount;

  User({
    required this.id,
    required this.username,
    this.nickname,
    this.avatar,
    this.bio,
    this.gender,
    this.points = 0,
    this.workouts = 0,
    this.streak = 0,
    this.lastWorkoutAt,
    this.isExpert = false,
    this.postCount = 0,
    this.followerCount = 0,
    this.followingCount = 0,
    this.likeCount = 0,
  });

  factory User.empty() => User(
        id: 0,
        username: '',
        nickname: '',
        avatar: '',
        bio: '',
        gender: '男',
        postCount: 0,
        followerCount: 0,
        followingCount: 0,
        likeCount: 0,
        points: 0,
        workouts: 0,
      );

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      nickname: json['nickname'],
      avatar: json['avatar'],
      bio: json['bio'],
      gender: json['gender'],
      points: json['points'] ?? 0,
      workouts: json['workouts'] ?? 0,
      streak: json['streak'] ?? 0,
      lastWorkoutAt: json['last_workout_at'] != null
          ? DateTime.parse(json['last_workout_at'])
          : null,
      isExpert: json['is_expert'] == 1,
      postCount: json['post_count'] ?? 0,
      followerCount: json['follower_count'] ?? 0,
      followingCount: json['following_count'] ?? 0,
      likeCount: json['like_count'] ?? 0,
    );
  }

  int get level {
    if (points >= 5000) return 5;
    if (points >= 3000) return 4;
    if (points >= 1500) return 3;
    if (points >= 500) return 2;
    return 1;
  }
}