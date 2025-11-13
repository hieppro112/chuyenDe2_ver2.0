// services/post_approval_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:giao_tiep_sv_user/duyet_Nguoi_Dung/models/User_post_approval_model.dart';

class PostApprovalService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Lấy danh sách bài viết chờ duyệt (status_id = 0)
  Stream<QuerySnapshot> getPendingPosts({
    int limit = 10,
    DocumentSnapshot? startAfter,
  }) {
    Query query = _firestore
        .collection('Post')
        .where('status_id', isEqualTo: 0) // Chỉ lấy bài chờ duyệt
        .orderBy('date_created', descending: true)
        .limit(limit);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    return query.snapshots();
  }

  // Lấy thông tin người dùng
  Future<Map<String, String>> _getUserInfo(String userId) async {
    try {
      final doc = await _firestore.collection('Users').doc(userId).get();
      if (doc.exists) {
        return {
          'fullname': doc['fullname'] ?? 'Ẩn danh',
          'avatar':
              doc['avt'] ??
              'https://cellphones.com.vn/sforum/wp-content/uploads/2023/10/avatar-trang-4.jpg',
        };
      }
    } catch (e) {
      print('Lỗi lấy user: $e');
    }
    return {
      'fullname': 'Ẩn danh',
      'avatar':
          'https://cellphones.com.vn/sforum/wp-content/uploads/2023/10/avatar-trang-4.jpg',
    };
  }

  // Chuyển đổi DocumentSnapshot → UserPostApprovalModel
  Future<UserPostApprovalModel> docToPostModel(DocumentSnapshot doc) async {
    final data = doc.data() as Map<String, dynamic>;
    final userId = data['user_id'] as String?;
    final userInfo = userId != null
        ? await _getUserInfo(userId)
        : {'fullname': 'Ẩn danh', 'avatar': ''};

    List<String> images = [];
    if (data['image_urls'] is List) {
      images = List<String>.from(data['image_urls']);
    } else if (data['file_url'] is String &&
        data['file_url'].toString().isNotEmpty) {
      images = [data['file_url']];
    }

    return UserPostApprovalModel(
      id: doc.id,
      authorName: userInfo['fullname']!,
      content: data['content'] ?? '',
      image: images.isNotEmpty ? images[0] : '',
      date: (data['date_created'] as Timestamp).toDate(),
      status: 'pending', // vì đang lấy status_id = 0
      reviewType: 'post',
    );
  }

  // Duyệt bài viết
  Future<void> approvePost(String postId) async {
    await _firestore.collection('Post').doc(postId).update({
      'status_id': 1, // Đã duyệt
    });
  }

  // Từ chối bài viết
  Future<void> rejectPost(String postId) async {
    await _firestore.collection('Post').doc(postId).update({
      'status_id': 2, // Từ chối
    });
  }
}
