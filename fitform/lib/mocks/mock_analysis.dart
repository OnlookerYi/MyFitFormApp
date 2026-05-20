import '../models/workout_analysis.dart';

WorkoutAnalysis mockAnalysis() {
  return WorkoutAnalysis(
    id: 1,
    userId: 1,
    exerciseType: '深蹲',
    score: 87.5,
    duration: 45,
    calories: 320,
    feedback: '整体动作标准，注意膝盖不要内扣',
    createdAt: '2026-05-18 12:00:00',
  );
}