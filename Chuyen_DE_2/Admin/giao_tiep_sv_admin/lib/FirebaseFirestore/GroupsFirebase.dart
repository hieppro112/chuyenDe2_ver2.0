import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:giao_tiep_sv_admin/Data/Group.dart';

class Groupsfirebase {
  final FirebaseFirestore groupDb = FirebaseFirestore.instance;

  Future<void> createGroupAdmin(Group group) async {
    try {
      await groupDb.collection("Groups").doc(group.id).set(group.tomap());
      print("tao nhom oke");
    } catch (e) {
      print("tao nhom loi : $e");
      rethrow;
    }
  }

  // Thêm phương thức cập nhật status_id
  Future<void> updateGroupStatus(String groupId, int statusId) async {
    try {
      await groupDb.collection("Groups").doc(groupId).update({
        'status_id': statusId,
      });
      print("Cap nhat trang thai nhom thanh cong");
    } catch (e) {
      print("Loi cap nhat trang thai nhom: $e");
      rethrow;
    }
  }
}
