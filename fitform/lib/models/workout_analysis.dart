class WorkoutAnalysis {
  final int id;
  final int userId;              // ✅ 必须有
  final String exerciseType;
  final double score;
  final int duration;
  final int calories;
  final String feedback;
  final String createdAt;

  WorkoutAnalysis({
    required this.id,
    required this.userId,        // ✅ 初始化
    required this.exerciseType,
    required this.score,
    required this.duration,
    required this.calories,
    required this.feedback,
    required this.createdAt,
  });

  factory WorkoutAnalysis.fromJson(Map<String, dynamic> json) {
    return WorkoutAnalysis(
      id: json['id'],
      userId: json['user_id'],
      exerciseType: json['exercise_type'] ?? '',
      score: (json['score'] as num).toDouble(),
      duration: json['duration'],
      calories: json['calories'],
      feedback: json['feedback'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'exercise_type': exerciseType,
        'score': score,
        'duration': duration,
        'calories': calories,
        'feedback': feedback,
        'created_at': createdAt,
      };
}