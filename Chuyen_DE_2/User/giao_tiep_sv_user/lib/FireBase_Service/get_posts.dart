import 'package:cloud_firestore/cloud_firestore.dart';

class GetPosts {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Hỗ trợ tra cứu thông tin người dùng từ Collection 'Users'
  Future<Map<String, dynamic>> _fetchUserDetail(String userId) async {
    try {
      final userDoc = await _firestore.collection('Users').doc(userId).get();
      if (userDoc.exists && userDoc.data() != null) {
        final userData = userDoc.data()!;
        return {
          // Lấy key 'fullname'
          "fullname": userData["fullname"] ?? "Ẩn danh",
          // Lấy key 'avt' từ Firestore (avatar)
          "avatar":
              userData["avt"] ??
              "https://cellphones.com.vn/sforum/wp-content/uploads/2023/10/avatar-trang-4.jpg",
        };
      }
    } catch (e) {
      print("Lỗi tra cứu thông tin người dùng: $e");
    }
    return {};
  }

  /// Lấy tất cả bài viết từ Firestore với status_id = 1
  Future<List<Map<String, dynamic>>> fetchPosts() async {
    try {
      final snapshot = await _firestore
          .collection('Post')
          // LỌC THEO STATUS_ID
          .where('status_id', isEqualTo: 1)
          .orderBy('date_created', descending: true)
          .get();

      // ... (Phần tra cứu chi tiết người dùng)
      final postsWithDetails = await Future.wait(
        snapshot.docs.map((doc) async {
          final data = doc.data();
          final userId = data["user_id"] as String?;
          Map<String, dynamic> userDetails = {};

          if (userId != null && userId.isNotEmpty) {
            userDetails = await _fetchUserDetail(userId);
          }

          return {
            "id": doc.id,
            "user_id": userId ?? "Ẩn danh",
            "fullname": userDetails["fullname"] ?? "Ẩn danh",
            "avatar": userDetails["avatar"],
            "group": data["group_id"] ?? "Không rõ",
            "title": data["content"] ?? "Không có nội dung",
            "date": (data["date_created"] is Timestamp)
                ? (data["date_created"] as Timestamp).toDate().toString()
                : null,
            "images": data["image_urls"] ?? [],
            "likes": 0,
            "isLiked": false,
            "comments": <Map<String, dynamic>>[],
          };
        }).toList(),
      );

      return postsWithDetails;
    } catch (e) {
      print("🔥 Lỗi tải bài viết từ PostService: $e");
      print(
        ">>> Gợi ý: Kiểm tra Firebase Console nếu có thông báo thiếu Index cho Query OrderBy + Where.",
      );
      return [];
    }
  }
}
