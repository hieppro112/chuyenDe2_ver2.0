// FireBase_Service/create_post.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class CreatePostService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ID người dùng mặc định theo yêu cầu của bạn
  static const String defaultUserId = "23211TT1234";

  /// Đẩy bài viết mới lên Firestore
  /// Trả về true nếu thành công, false nếu thất bại
  Future<bool> uploadPost({
    required String content,
    required String groupId,
    String? fileUrl, // Dùng cho ảnh hoặc file đầu tiên
    // List<String>? fileUrls, // Nếu muốn hỗ trợ nhiều file/ảnh
  }) async {
    try {
      final postData = {
        "user_id": defaultUserId,
        "content": content,
        "group_id": groupId,
        "date_created":
            FieldValue.serverTimestamp(), // Tự động lấy thời gian máy chủ
        "file_url": fileUrl, // Lưu URL ảnh/file
        "status_id": 1, // Ví dụ: 1 là đã duyệt
        "id_port": "ABC", // Giữ nguyên giá trị mặc định của bạn
      };

      await _firestore.collection('Post').add(postData);

      print("✅ Đăng bài lên Firestore thành công!");
      return true;
    } catch (e) {
      print("🔥 LỖI KHI ĐĂNG BÀI: $e");
      return false;
    }
  }
}
