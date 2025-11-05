// FireBase_Service/create_post.dart (ĐÃ SỬA)

import 'package:cloud_firestore/cloud_firestore.dart';

class CreatePostService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Đẩy bài viết mới lên Firestore
  /// YÊU CẦU currentUserId TỪ HÀM ĐĂNG NHẬP
  Future<bool> uploadPost({
    required String currentUserId,
    required String content,
    required String groupId,
    String? fileUrl,
  }) async {
    try {
      final postData = {
        "user_id": currentUserId,
        "content": content,
        "group_id": groupId,
        "date_created": FieldValue.serverTimestamp(),
        "file_url": fileUrl,
        "status_id": 1,
        "id_port": "ABC",
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
