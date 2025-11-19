import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AdminActionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // CHUYỂN ĐỔI THỜI GIAN
  String formatDate(dynamic timestamp) {
    if (timestamp is Timestamp) {
      DateTime date = timestamp.toDate();
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    }
    return 'Không rõ thời gian';
  }

  // TẢI CHI TIẾT BÀI VIẾT
  Future<Map<String, dynamic>?> fetchPostDetails(String postId) async {
    if (postId.isEmpty) return null;
    try {
      final postDoc = await _firestore.collection('Post').doc(postId).get();

      if (postDoc.exists) return postDoc.data();
    } catch (e) {
      print('Lỗi tải bài viết: $e');
    }
    return null;
  }

  /// GỬI CẢNH BÁO VÀ CẬP NHẬT TRẠNG THÁI BÁO CÁO
  Future<bool> sendWarningAndMarkResolved(
    BuildContext context,
    String recipientId,
    String reportDocId,
  ) async {
    if (recipientId.isEmpty || reportDocId.isEmpty) return false;

    try {
      // Giả định: Cần lấy tên người dùng từ collection Users để truyền vào Notifycations
      // Tạm thời dùng tên mặc định:
      const String recipientName = "Người dùng";

      final notificationData = {
        'title': "Cảnh báo đăng bài không đúng quy chuẩn cộng đồng",
        'content':
            "Bạn đã đăng bài không đúng quy chuẩn của cộng đồng, vui lòng đăng bài 1 cách văn minh. NẾU PHÁT HIỆN CÓ HÀNH VI QUÁ MỨC SẼ KHÓA TÀI KHOẢN!",
        'type_notify': 1,
        'id_status': 0, // Trạng thái chưa đọc
        'user_recipient_id': {recipientId: recipientName},
        'created_at': FieldValue.serverTimestamp(),
      };

      // 1. Gửi thông báo cảnh báo
      await _firestore.collection('Notifycations').add(notificationData);

      // 2. Cập nhật trạng thái bản ghi báo cáo vi phạm
      // 🎯 SỬA LỖI: CẬP NHẬT COLLECTION BÁO CÁO VI PHẠM (Giả định là ViolationReports)
      await _firestore.collection('ViolationReports').doc(reportDocId).update({
        'id_status': 1, // Đánh dấu là đã xử lý/giải quyết
        'resolved_at': FieldValue.serverTimestamp(),
        'admin_action': 'Cảnh báo',
      });

      return true;
    } catch (e) {
      print('Lỗi khi gửi cảnh báo và cập nhật trạng thái: $e');
      return false;
    }
  }

  /// --- HÀM 4: XỬ LÝ KHÓA TÀI KHOẢN ---
  /// Cập nhật trường 'is_locked' = true trong document Users
  Future<bool> lockUserAccount(String userId) async {
    if (userId.isEmpty) return false;

    try {
      // 1. Truy cập document Users bằng userId
      await _firestore.collection('Users').doc(userId).update({
        'is_locked': true, // CẬP NHẬT TRẠNG THÁI KHÓA
      });

      print('✅ Đã khóa tài khoản thành công cho User ID: $userId');
      return true;
    } on FirebaseException catch (e) {
      // Xử lý trường hợp document không tồn tại hoặc lỗi khác
      print('🔥 LỖI KHÓA TÀI KHOẢN Firestore: ${e.message}');
      return false;
    } catch (e) {
      print('🔥 LỖI KHÔNG XÁC ĐỊNH khi khóa tài khoản: $e');
      return false;
    }
  }
}
