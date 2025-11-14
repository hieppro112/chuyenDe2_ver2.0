import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:giao_tiep_sv_user/duyet_Nguoi_Dung/models/MemberApprovalModel.dart';

class MemberApprovalService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'Groups_members';

  /// [SỬA - 14/11/2025 23:15]
  /// - Bỏ .where('status_id', isEqualTo: 0) để lấy TẤT CẢ trạng thái (pending, approved, rejected)
  /// - Tăng limit mặc định lên 100
  /// → Mục đích: Hiển thị thành viên đã duyệt/từ chối, không bị mất khi lọc
  Stream<QuerySnapshot> getPendingMembers({
    int limit = 100, // [SỬA - 14/11/2025 23:15] Tăng từ 10 → 100
    DocumentSnapshot? startAfter,
    required String groupId,
  }) {
    Query query = _firestore
        .collection(_collection)
        .where('group_id', isEqualTo: groupId)
        // [SỬA - 14/11/2025 23:15] BỎ DÒNG: .where('status_id', isEqualTo: 0)
        .orderBy('joined_at', descending: true)
        .limit(limit);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    return query.snapshots();
  }

  Future<MemberApprovalModel> docToMemberModel(
    QueryDocumentSnapshot doc,
  ) async {
    final data = doc.data() as Map<String, dynamic>;

    String fullName = 'Không tên';
    String avatar = '';
    String? faculty;
    String? facultyId;
    String? academicYear;

    final String? userId = data['user_id'] as String?;

    if (userId != null && userId.isNotEmpty) {
      try {
        final userDoc = await _firestore.collection('Users').doc(userId).get();

        if (userDoc.exists) {
          final userData = userDoc.data()!;
          fullName = userData['fullname'] ?? 'Không tên';
          avatar = userData['avt'] ?? '';
          facultyId = userData['faculty_id']?.toString();

          if (facultyId != null && facultyId.isNotEmpty) {
            try {
              final facultySnapshot = await _firestore
                  .collection('Faculty')
                  .where('id', isEqualTo: facultyId)
                  .limit(1)
                  .get();

              if (facultySnapshot.docs.isNotEmpty) {
                final facultyDoc = facultySnapshot.docs.first;
                faculty = facultyDoc['name'] ?? 'Không rõ khoa';
              } else {
                faculty = facultyId;
              }
            } catch (e) {
              faculty = facultyId;
            }
          }
        }
      } catch (e, s) {
        print("Lỗi khi lấy user: $e\n$s");
      }
    }

    final int statusId = (data['status_id'] as num?)?.toInt() ?? 0;
    final String status = _statusIdToString(statusId);

    return MemberApprovalModel(
      id: doc.id,
      userId: userId ?? '',
      fullName: fullName,
      avatar: avatar,
      groupId: data['group_id'] ?? '',
      role: _roleToString((data['role'] as num?)?.toInt() ?? 0),
      status: status,
      joinedAt: (data['joined_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      faculty: faculty,
      facultyId: facultyId,
      academicYear: academicYear,
    );
  }

  Future<void> approveMember(String docId) async {
    await _firestore.collection(_collection).doc(docId).update({
      'status_id': 1,
    });
  }

  Future<void> rejectMember(String docId) async {
    await _firestore.collection(_collection).doc(docId).update({
      'status_id': 2,
    });
  }

  String _statusIdToString(int id) {
    switch (id) {
      case 0:
        return 'pending';
      case 1:
        return 'approved';
      case 2:
        return 'rejected';
      default:
        return 'pending';
    }
  }

  String _roleToString(int id) {
    switch (id) {
      case 0:
        return 'member';
      case 1:
        return 'admin';
      default:
        return 'member';
    }
  }
}
