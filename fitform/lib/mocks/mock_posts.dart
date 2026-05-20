import '../models/post.dart';

Post mockImagePost() {
  return Post(
    id: 1,
    authorId: 1,
    content: '今天的力量训练 💪',
    type: PostType.image,
    images: [
      'https://picsum.photos/400/300',
      'https://picsum.photos/400/301',
    ],
    likeCount: 12,
    commentCount: 3,
    collectCount: 1,
  );
}

Post mockVideoPost() {
  return Post(
    id: 2,
    authorId: 1,
    content: '深蹲教学',
    type: PostType.video,
    videoUrl: 'https://www.w3schools.com/html/mov_bbb.mp4',
    likeCount: 30,
    commentCount: 5,
  );
}

Post mockAnalysisPost() {
  return Post(
    id: 3,
    authorId: 1,
    content: 'AI 动作分析',
    type: PostType.analysis,
    analysisId: 1,
    likeCount: 18,
  );
}