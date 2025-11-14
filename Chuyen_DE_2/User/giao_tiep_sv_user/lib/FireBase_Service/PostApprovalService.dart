// services/post_approval_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:giao_tiep_sv_user/duyet_Nguoi_Dung/models/User_post_approval_model.dart';

class PostApprovalService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // [SỬA - 14/11/2025 23:59] Tối ưu: Lấy tất cả user info 1 lần
  // [SỬA - 15/11/2025 01:00] Giữ lại method cũ để tương thích nếu cần
  Stream<QuerySnapshot> getPendingPosts({
    int limit = 10,
    DocumentSnapshot? startAfter,
  }) {
    Query query = _firestore
        .collection('Post')
        .where('status_id', isEqualTo: 0)
        .orderBy('date_created', descending: true)
        .limit(limit);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    return query.snapshots(); // Realtime!
  }

  // [SỬA - 15/11/2025 01:00] MỚI: Lấy bài viết theo trạng thái
  // statusId = -1 → Tất cả, 0 → pending, 1 → approved, 2 → rejected
  Stream<QuerySnapshot> getPostsByStatus({
    int limit = 20,
    DocumentSnapshot? startAfter,
    int statusId = -1,
  }) {
    Query query = _firestore
        .collection('Post')
        .orderBy('date_created', descending: true)
        .limit(limit);

    if (statusId >= 0) {
      query = query.where('status_id', isEqualTo: statusId);
    }

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    return query.snapshots(); // Realtime cho mọi trạng thái
  }

  // [SỬA - 14/11/2025 23:59] Tối ưu: Lấy nhiều user cùng lúc
  Future<Map<String, Map<String, String>>> _getUsersInfo(
    List<String> userIds,
  ) async {
    if (userIds.isEmpty) return {};

    try {
      final snapshots = await _firestore
          .collection('Users')
          .where(FieldPath.documentId, whereIn: userIds)
          .get();

      final Map<String, Map<String, String>> result = {};
      for (var doc in snapshots.docs) {
        result[doc.id] = {
          'fullname': doc['fullname'] ?? 'Ẩn danh',
          'avatar':
              doc['avt'] ??
              'https://cellphones.com.vn/sforum/wp-content/uploads/2023/10/avatar-trang-4.jpg',
        };
      }
      return result;
    } catch (e) {
      print('Lỗi batch user: $e');
      return {};
    }
  }

  // [SỬA - 14/11/2025 23:59] Dùng batch
  // [SỬA - 15/11/2025 01:00] Sửa: Dùng status_id thực tế từ Firestore
  Future<List<UserPostApprovalModel>> docsToPostModels(
    List<QueryDocumentSnapshot> docs,
  ) async {
    if (docs.isEmpty) return [];

    // Lấy tất cả user_id
    final userIds = docs
        .map((doc) => doc['user_id'] as String?)
        .where((id) => id != null && id.isNotEmpty)
        .cast<String>()
        .toSet()
        .toList();

    // Lấy info user 1 lần
    final usersMap = await _getUsersInfo(userIds);

    final List<UserPostApprovalModel> posts = [];
    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final userId = data['user_id'] as String?;
      final userInfo =
          usersMap[userId] ??
          {
            'fullname': 'Ẩn danh',
            'avatar':
                'https://cellphones.com.vn/sforum/wp-content/uploads/2023/10/avatar-trang-4.jpg',
          };

      List<String> images = [];
      if (data['image_urls'] is List) {
        images = List<String>.from(data['image_urls']);
      } else if (data['file_url'] is String &&
          data['file_url'].toString().isNotEmpty) {
        images = [data['file_url']];
      }

      // [SỬA - 15/11/2025 01:00] Lấy status_id từ Firestore
      final int statusId = (data['status_id'] as num?)?.toInt() ?? 0;
      final String status = _statusIdToString(statusId);

      posts.add(
        UserPostApprovalModel(
          id: doc.id,
          authorName: userInfo['fullname']!,
          content: data['content'] ?? '',
          image: images.isNotEmpty ? images[0] : '',
          date: (data['date_created'] as Timestamp).toDate(),
          status: status, // Dùng status thực tế
          reviewType: 'post',
        ),
      );
    }
    return posts;
  }

  // [SỬA - 15/11/2025 01:00] Helper: Chuyển status_id → string
  String _statusIdToString(int id) {
    switch (id) {
      case 0:
        return 'pending';
      case 1:
        return 'approved';
      case 2:
        return 'rejected';
      default:
        return 'pending';
    }
  }

  Future<void> approvePost(String postId) async {
    await _firestore.collection('Post').doc(postId).update({'status_id': 1});
  }

  Future<void> rejectPost(String postId) async {
    await _firestore.collection('Post').doc(postId).update({'status_id': 2});
  }
}
