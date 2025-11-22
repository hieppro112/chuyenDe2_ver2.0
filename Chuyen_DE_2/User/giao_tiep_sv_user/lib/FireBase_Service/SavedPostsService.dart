import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SavedPostsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Map<String, dynamic>>> streamSavedPosts(String studentId) {
    if (studentId.isEmpty) return Stream.value([]);

    print("BẮT ĐẦU streamSavedPosts với studentId: '$studentId'");

    return _firestore
        .collection('Post_save')
        .where('user_id', isEqualTo: studentId)
        .orderBy('create_at', descending: true)
        .snapshots()
        .asyncMap((saveSnapshot) async {
          print("Post_save snapshot: ${saveSnapshot.docs.length} documents");

          final postIds = saveSnapshot.docs
              .map((d) => d['post_id'] as String)
              .toList();
          print("postIds tìm được: $postIds");

          if (postIds.isEmpty) return [];

          final List<Map<String, dynamic>> results = [];

          for (final postId in postIds) {
            print("Lấy bài viết: $postId");
            try {
              final postDoc = await _firestore
                  .collection('Post')
                  .doc(postId)
                  .get();

              if (postDoc.exists) {
                final data = postDoc.data()!;
                data['id'] = postDoc.id;

                final saveDoc = saveSnapshot.docs.firstWhere(
                  (d) => d['post_id'] == postId,
                );
                data['saved_at'] = (saveDoc['create_at'] as Timestamp?)
                    ?.toDate();

                // LẤY THÔNG TIN USER TỪ COLLECTION Users
                final String postUserId = data['user_id'] as String;
                final userDoc = await _firestore
                    .collection('Users')
                    .doc(postUserId)
                    .get();

                if (userDoc.exists) {
                  final userData = userDoc.data()!;
                  data['user_name'] =
                      userData['fullname'] as String? ?? 'Ẩn danh';
                  data['user_faculty'] =
                      userData['faculty_id'] as String? ?? 'Chưa cập nhật';
                } else {
                  data['user_name'] = 'Ẩn danh';
                  data['user_faculty'] = 'Chưa cập nhật';
                }

                results.add(data);
              } else {
                print("KHÔNG TÌM THẤY Post: $postId");
              }
            } catch (e) {
              print("LỖI lấy post $postId: $e");
            }
          }
          return results;
        });
  }

  /// Xóa bài đã lưu
  Future<void> unsavePost(String studentId, String postId) async {
    if (studentId.isEmpty) return;

    final snapshot = await _firestore
        .collection('Post_save')
        .where('user_id', isEqualTo: studentId)
        .where('post_id', isEqualTo: postId)
        .get();

    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  /// Lưu bài (khi bấm "Lưu")
  Future<void> savePost(String studentId, String postId) async {
    if (studentId.isEmpty) return;

    final exists = await _firestore
        .collection('Post_save')
        .where('user_id', isEqualTo: studentId)
        .where('post_id', isEqualTo: postId)
        .limit(1)
        .get();

    if (exists.docs.isNotEmpty) return;

    await _firestore.collection('Post_save').add({
      'user_id': studentId,
      'post_id': postId,
      'create_at': FieldValue.serverTimestamp(),
    });
  }

  // -----------------------------------------------------------------
  List<List<T>> _chunk<T>(List<T> list, int size) {
    return [
      for (var i = 0; i < list.length; i += size)
        list.sublist(i, i + size > list.length ? list.length : i + size),
    ];
  }
}
