// data/repositories/post_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:giao_tiep_sv_user/Data/posts.dart';
import 'package:giao_tiep_sv_user/Profile/personalPost/models/personal_post_model.dart';

class PostRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Cache đơn giản (tránh gọi nhiều lần)
  final Map<String, String> _userCache = {};
  final Map<String, String> _groupCache = {};

  // Lấy fullname
  Future<String> _getUserName(String userId) async {
    if (_userCache.containsKey(userId)) return _userCache[userId]!;
    final doc = await _firestore.collection('Users').doc(userId).get();
    final name = doc.exists
        ? doc['fullname'] as String? ?? 'Ẩn danh'
        : 'Ẩn danh';
    _userCache[userId] = name;
    return name;
  }

  // Lấy group name
  Future<String> _getGroupName(String groupId) async {
    if (_groupCache.containsKey(groupId)) return _groupCache[groupId]!;
    final doc = await _firestore.collection('Groups').doc(groupId).get();
    final name = doc.exists ? doc['name'] as String? ?? 'Không rõ' : 'Không rõ';
    _groupCache[groupId] = name;
    return name;
  }

  // Đếm like/comment (subcollection)
  Future<int> _countSubcollection(String postId, String sub) async {
    final snap = await _firestore
        .collection('Post')
        .doc(postId)
        .collection(sub)
        .get();
    return snap.size;
  }

  /// Stream bài viết cá nhân + join tên
  Stream<List<PersonalPostModel>> personalPostsStream(String currentUserId) {
    return _firestore
        .collection('Post')
        .where('user_id', isEqualTo: currentUserId)
        .orderBy('date_created', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
          final List<PersonalPostModel> result = [];

          for (final doc in snapshot.docs) {
            // DÙNG FACTORY - RÕ RÀNG, CHUẨN
            final post = Posts.fromFirestore(doc);

            final userName = await _getUserName(post.user_id);
            final groupName = await _getGroupName(post.group_id);

            // DÙNG doc.id CHO like/comment (vì đây là ID thật của Firestore)
            final likesCount = await _countSubcollection(doc.id, 'likes');
            final commentsCount = await _countSubcollection(doc.id, 'comments');

            // Kiểm tra like
            final likeDoc = await _firestore
                .collection('Post')
                .doc(doc.id)
                .collection('likes')
                .doc(currentUserId)
                .get();
            final isLiked = likeDoc.exists;

            result.add(
              PersonalPostModel(
                id: doc.id, // ID thật để thao tác
                userId: post.user_id,
                groupId: post.group_id,
                title: post.content,
                image: post.file_url ?? '',
                createdAt: post.date_created,
                likesCount: likesCount, // Đã khai báo
                commentsCount: commentsCount,
                isLiked: isLiked,
                userName: userName,
                groupName: groupName,
              ),
            );
          }
          return result;
        });
  }
}
