import '../models/comment.dart';

List<Comment> mockComments(int postId) {
  return [
    Comment(
      id: 1,
      postId: postId,
      userId: 1,
      parentId: null,
      content: '太强了！',
      createdAt: '2026-05-18 12:00',
      likeCount: 3,
    ),
    Comment(
      id: 2,
      postId: postId,
      userId: 2,
      parentId: 1,   // ✅ 回复第一条
      content: '谢谢支持 🙏',
      createdAt: '2026-05-18 12:01',
      likeCount: 1,
    ),
  ];
}