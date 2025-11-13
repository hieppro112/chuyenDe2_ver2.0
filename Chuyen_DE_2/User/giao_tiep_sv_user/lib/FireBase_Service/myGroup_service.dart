import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:giao_tiep_sv_user/Data/global_state.dart';

class MygroupService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Stream danh sách nhóm được tạo bởi user hiện tại
  static Stream<QuerySnapshot> getMyGroupsStream() {
    return _firestore
        .collection('Groups')
        .where('created_by', isEqualTo: GlobalState.currentUserId)
        .snapshots();
  }
}
