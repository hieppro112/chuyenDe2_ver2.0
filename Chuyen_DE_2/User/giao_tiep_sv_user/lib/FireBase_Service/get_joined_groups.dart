// FireBase_Service/get_joined_groups.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GetJoinedGroupsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Lấy danh sách nhóm mà người dùng đã tham gia
  Future<List<Map<String, dynamic>>> fetchJoinedGroups(String userId) async {
    // 1. Thêm nhóm "Tất cả" mặc định
    List<Map<String, dynamic>> resultGroups = [
      {"name": "Tất cả", "icon": Icons.public, "id": "ALL"},
    ];

    if (userId.isEmpty) {
      print("Service: User ID trống, chỉ trả về nhóm mặc định.");
      return resultGroups;
    }

    try {
      // 2. Truy vấn Collection Groups_members để lấy các group_id mà user đã tham gia
      // Lọc theo status_id = 1 (Đã được phê duyệt)
      final memberSnapshot = await _firestore
          .collection('Groups_members')
          .where('user_id', isEqualTo: userId)
          .where('status_id', isEqualTo: 1)
          .get();

      final groupIds = memberSnapshot.docs
          .map((doc) => doc['group_id'] as String)
          .toList();

      if (groupIds.isEmpty) {
        print(
          "Service: User $userId chưa tham gia nhóm nào được duyệt (status_id=1).",
        );
        return resultGroups;
      }

      // 3. Tra cứu thông tin nhóm chi tiết (Lookup)
      List<Future<Map<String, dynamic>?>> groupsFutures = [];

      for (final groupId in groupIds) {
        groupsFutures.add(_fetchGroupDetails(groupId));
      }

      final fetchedGroups = await Future.wait(groupsFutures);

      // ✅ SỬA LỖI ÉP KIỂU: Lọc bỏ các kết quả null và chuyển sang List đúng kiểu
      final validGroups = fetchedGroups
          .whereType<Map<String, dynamic>>()
          .toList();

      // 4. Kết hợp và trả về
      resultGroups.addAll(validGroups);
      print("Service: Đã tải ${validGroups.length} nhóm thành công.");
      return resultGroups;
    } catch (e) {
      print("🔥 Service: Lỗi tải danh sách nhóm: $e");
      print(">>> Gợi ý: Vui lòng kiểm tra lại quy tắc bảo mật Firestore.");
      return resultGroups;
    }
  }

  // Hàm tra cứu chi tiết thông tin nhóm từ Collection 'Groups'
  Future<Map<String, dynamic>?> _fetchGroupDetails(String groupId) async {
    try {
      final groupDoc = await _firestore.collection('Groups').doc(groupId).get();
      if (groupDoc.exists && groupDoc.data() != null) {
        final data = groupDoc.data()!;
        return {
          "name": data["name"] ?? "Nhóm không tên",
          "icon": _mapGroupToIcon(data["name"] ?? ""),
          "id": groupId,
        };
      }
    } catch (e) {
      // Bỏ qua lỗi tra cứu chi tiết một nhóm cụ thể
    }
    return null;
  }

  // Hàm ánh xạ tên nhóm sang Icon
  IconData _mapGroupToIcon(String groupName) {
    final lowerName = groupName.toLowerCase();
    if (lowerName.contains("mobile") || lowerName.contains("flutter")) {
      return Icons.phone_android;
    } else if (lowerName.contains("thiết kế") || lowerName.contains("đồ họa")) {
      return Icons.computer;
    } else if (lowerName.contains("cntt") || lowerName.contains("công nghệ")) {
      return Icons.school;
    } else if (lowerName.contains("dev") || lowerName.contains("vui vẻ")) {
      return Icons.developer_mode;
    }
    return Icons.people;
  }
}
