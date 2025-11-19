// group_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../Data/global_state.dart';

class GroupService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- HÀM TRÍCH XUẤT MÃ KHOA ---
  String _extractFacultyCode(String userId) {
    if (userId.isEmpty) return '';

    // Regex tìm cụm chữ cái in hoa (A-Z) liên tiếp
    final RegExp facultyRegex = RegExp(r'[A-Z]+');
    final Iterable<RegExpMatch> matches = facultyRegex.allMatches(userId);

    if (matches.isNotEmpty) {
      return matches.first.group(0)!;
    } else {
      return '';
    }
  }

  // --- HÀM TRUY VẤN VÀ LỌC NHÓM ĐỂ THAM GIA ---
  // Điều kiện lọc: Cùng Khoa, Nhóm đã được duyệt (id_status=1 & approval_mode=true),
  // và Người dùng chưa có bản ghi (status_id=0 hoặc 1) trong Groups_members.
  Future<List<DocumentSnapshot>> fetchGroupsToJoin() async {
    final String currentUserId = GlobalState.currentUserId;
    final String facultyCode = _extractFacultyCode(currentUserId);

    if (currentUserId.isEmpty || facultyCode.isEmpty) {
      return [];
    }

    // 1. Lấy tất cả các bản ghi của người dùng trong Groups_members
    final QuerySnapshot memberGroupsSnapshot = await _firestore
        .collection('Groups_members')
        .where('user_id', isEqualTo: currentUserId)
        .get();

    // 2. Lọc ra các Group ID mà người dùng ĐANG CHỜ DUYỆT (0) HOẶC ĐÃ ĐƯỢC CHẤP NHẬN (1)
    final Set<String> groupIdsToExclude = memberGroupsSnapshot.docs
        .where((doc) {
          final status = doc.get('status_id') as int?;
          // Loại trừ nhóm nếu user ĐÃ CHẤP NHẬN (1) HOẶC ĐANG CHỜ DUYỆT (0)
          return status == 1 || status == 0;
        })
        .map((doc) => doc['group_id'] as String)
        .toSet();

    // 3. Truy vấn danh sách tất cả các nhóm theo điều kiện
    final QuerySnapshot allGroupsSnapshot = await _firestore
        .collection('Groups')
        .where('faculty_id', isEqualTo: facultyCode)
        .where('id_status', isEqualTo: 1) // Nhóm đã được duyệt (Status ID)
        .get();

    // 4. Lọc bỏ các nhóm mà người dùng đã có mặt trong groupIdsToExclude
    final List<DocumentSnapshot> filteredGroups = allGroupsSnapshot.docs
        .where((groupDoc) => !groupIdsToExclude.contains(groupDoc.id))
        .toList();

    return filteredGroups;
  }

  // --- HÀM GỬI YÊU CẦU THAM GIA NHÓM ---
  Future<void> requestJoinGroup(String groupId) async {
    final String currentUserId = GlobalState.currentUserId;

    await _firestore.collection('Groups_members').add({
      'group_id': groupId,
      'user_id': currentUserId,
      'role': 1, // Thành viên thường
      'status_id': 0, // Đang chờ duyệt
      'joined_at': FieldValue.serverTimestamp(),
    });
  }
}
