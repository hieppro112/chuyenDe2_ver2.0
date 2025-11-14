// MygroupService.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:giao_tiep_sv_user/Data/global_state.dart';

class MygroupService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Stream danh sách nhóm được tạo bởi user hiện tại
  /// chỉ lấy các nhóm có id_status = 1 (Đã duyệt/Hoạt động)
  static Stream<QuerySnapshot> getMyGroupsStream() {
    return _firestore
        .collection('Groups')
        // Lọc theo người tạo
        .where('created_by', isEqualTo: GlobalState.currentUserId)
        // id_status = 1
        .where('id_status', isEqualTo: 1) 
        .snapshots();
  }
}