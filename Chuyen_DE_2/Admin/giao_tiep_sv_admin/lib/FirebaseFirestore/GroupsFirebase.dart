import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:giao_tiep_sv_admin/Data/Group.dart';

class Groupsfirebase {
  final FirebaseFirestore groupDb = FirebaseFirestore.instance;
  //tao nhom dua len firebase
  Future<void> createGroupAdmin(Group group) async {
    try {
      await groupDb.collection("Groups").doc(group.id).set(group.tomap());
      print("tao nhom oke");
    } catch (e) {
      print("tao nhom loi : $e");
      rethrow;
    }
  }
}