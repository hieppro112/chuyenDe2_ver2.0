import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GetJoinedGroupsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Hàm ánh xạ tên nhóm sang Icon (giữ lại để làm fallback nếu không có ảnh)
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

  // Hàm tra cứu chi tiết thông tin nhóm từ Collection 'Groups'
  // CHỈ chấp nhận Group có id_status = 1
  Future<Map<String, dynamic>?> _fetchGroupDetails(String groupId) async {
    try {
      final groupDoc = await _firestore.collection('Groups').doc(groupId).get();
      if (groupDoc.exists && groupDoc.data() != null) {
        final data = groupDoc.data()!;

        // >> ĐÃ SỬA: Kiểm tra trường "id_status" trong collection Groups
        if (data["id_status"] != 1) {
          return null; // Loại bỏ nếu Group không hoạt động (id_status != 1)
        }

        // URL ảnh mặc định nếu không có ảnh nhóm
        const defaultAvatarUrl = "https://picsum.photos/seed/group/50";

        return {
          "name": data["name"] ?? "Nhóm không tên",
          "avatar_url": data["avt"] ?? defaultAvatarUrl,
          "icon": _mapGroupToIcon(data["name"] ?? ""),
          "id": groupId,
        };
      }
    } catch (e) {
      // Bỏ qua lỗi tra cứu chi tiết một nhóm cụ thể
    }
    return null;
  }

  /// Lấy danh sách nhóm mà người dùng đã tham gia
  Future<List<Map<String, dynamic>>> fetchJoinedGroups(String userId) async {
    // Giữ lại mục "Tất cả" (ID: ALL) để đảm bảo tính tương thích với các màn hình khác
    List<Map<String, dynamic>> resultGroups = [
      {"name": "Tất cả", "icon": Icons.public, "id": "ALL"},
    ];

    if (userId.isEmpty) {
      return resultGroups;
    }

    try {
      // >> ĐÃ SỬA: Lọc Groups_members với status_id BẰNG 1 (Member Status)
      final memberSnapshot = await _firestore
          .collection('Groups_members')
          .where('user_id', isEqualTo: userId)
          .where(
            'status_id',
            isEqualTo: 1,
          ) // Kiểm tra trường status_id trong Groups_members
          .get();

      final groupIds = memberSnapshot.docs
          .map((doc) => doc['group_id'] as String)
          .toList();

      if (groupIds.isEmpty) {
        return resultGroups;
      }

      List<Future<Map<String, dynamic>?>> groupsFutures = [];

      for (final groupId in groupIds) {
        // Mỗi group được kiểm tra Group Status (id_status=1) trong _fetchGroupDetails
        groupsFutures.add(_fetchGroupDetails(groupId));
      }

      final fetchedGroups = await Future.wait(groupsFutures);

      // Sau khi Future.wait chạy, chỉ những nhóm thỏa mãn cả 2 điều kiện mới còn lại
      final validGroups = fetchedGroups
          .whereType<Map<String, dynamic>>()
          .toList();

      resultGroups.addAll(validGroups);
      return resultGroups;
    } catch (e) {
      print("🔥 Service: Lỗi tải danh sách nhóm: $e");
      return resultGroups;
    }
  }
}
