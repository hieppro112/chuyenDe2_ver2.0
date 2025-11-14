// lib/Admin/services/admin_action_service.dart

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

  //  TẢI CHI TIẾT BÀI VIẾT
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
      // Lấy tên người dùng mặc định cho Map
      const String recipientName = "Người dùng";

      final notificationData = {
        'title': "Cảnh báo đăng bài không đúng quy chuẩn cộng đồng",
        'content':
            "Bạn đã đăng bài không đúng quy chuẩn của cộng đồng, vui lòng đăng bài 1 cách văn minh. NẾU PHÁT HIỆN CÓ HÀNH VI QUÁ MỨC SẼ KHÓA TÀI KHOẢN!",
        'type_notify': 1,
        'id_status': 0,
        'user_recipient_id': {recipientId: recipientName},
        'created_at': FieldValue.serverTimestamp(),
      };

      // 1. Gửi thông báo cảnh báo
      await _firestore.collection('Notifycations').add(notificationData);

      // 3. Cập nhật trạng thái bản ghi báo cáo
      await _firestore.collection('Notifycations').doc(reportDocId).update({
        'id_status': 1,
      });

      return true;
    } catch (e) {
      print('Lỗi khi gửi cảnh báo và cập nhật trạng thái: $e');
      return false;
    }
  }

  // --- HÀM 4: XỬ LÝ KHÓA TÀI KHOẢN (Placeholder) ---
  Future<bool> lockUserAccount(String userId) async {
    print('Thực hiện khóa tài khoản cho User ID: $userId');
    return true;
  }
}
