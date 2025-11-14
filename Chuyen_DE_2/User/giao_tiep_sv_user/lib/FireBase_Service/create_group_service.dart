import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:giao_tiep_sv_user/FireBase_Service/upload_service.dart'; // Giả định service này đã tồn tại

class CreateGroupService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final UploadService _uploadService = UploadService();

  /// Tạo một nhóm mới và thêm người tạo vào nhóm thành viên
  Future<bool> createGroup({
    required String creatorUserId,
    required String creatorFullname,
    required String name,
    required String description,
    File? groupImage,
    required String facultyId,
  }) async {
    try {
      String? imageUrl;

      // 1. Tải ảnh nhóm lên Firebase Storage nếu có
      if (groupImage != null) {
        // Dùng creatorUserId để tổ chức Storage Path
        imageUrl = await _uploadService.uploadFile(groupImage, creatorUserId);
        if (imageUrl == null) {
          print("⚠️ Lỗi: Không thể tải ảnh nhóm lên Storage.");
          return false;
        }
      }

      // 2. Tạo Group Document trong Collection 'Groups'
      final newGroupRef = _firestore.collection('Groups').doc();
      final groupData = {
        "id": newGroupRef.id,
        "name": name,
        "description": description,
        "type_group": 0,
        "approval_mode": true,
        "avt": imageUrl,
        "created_by": {creatorUserId: creatorFullname},
        "id_status": 0,
        "faculty_id": facultyId,
        "created_at": FieldValue.serverTimestamp(),
      };
      await newGroupRef.set(groupData);

      // 3. Tự động thêm người tạo vào Groups_members
      await _firestore.collection('Groups_members').add({
        "group_id": newGroupRef.id,
        "user_id": creatorUserId,
        "role": 1, // Vai trò: 1 = Quản trị viên
        "status_id": 1,
        "joined_at": FieldValue.serverTimestamp(),
      });

      print("✅ Tạo nhóm và thêm thành viên thành công: ${newGroupRef.id}");
      return true;
    } catch (e) {
      print("🔥 LỖI KHI TẠO NHÓM: $e");
      return false;
    }
  }
}
