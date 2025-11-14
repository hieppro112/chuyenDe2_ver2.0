import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:giao_tiep_sv_user/Data/groups_members.dart';

class GroupserviceManeger {
  final FirebaseFirestore groupDb = FirebaseFirestore.instance;

  //them vao membergroup
  Future<void> addDataGroupMember( GroupMember grMember)async{
    try{
      final querySnap = groupDb.collection("Groups_members");
      await querySnap.add({
        'group_id': grMember.group_id,
        'user_id': grMember.user_id,
        'role': 1, 
        'status_id': grMember.status_id, 
        'joined_at': FieldValue.serverTimestamp(), 
      });

    print("them thanh vien thanh cong");
    }catch(e){
      print("loi khi them thanh vien vao nhom: $e");
    }
  }
  // lay created at của nhóm 
  Future<String?> getCreateAtID(String idGroup)async{
    try{
      List<String> listResult =[];
      final querySnap = await groupDb.collection("Groups").doc(idGroup).get();
      if(querySnap.exists){
        Map<String,dynamic> data = querySnap.data() as Map<String,dynamic>;

        String? createBy = data["created_by"] as String?;
        
        if(createBy!=null){
          listResult.add(createBy);
          return createBy;
        }
        else{
          print("du lieu khong ton tai");
          return null;
        }
      }
    }catch(e){
      print("loi khi lay create At: $e");
      return null;
    }
  }
  //tim cac thanh vien ben trong nhom
  Future<List<String?>> listChat(String idRoom) async {
    try {
      final querySnap = await groupDb
          .collection("Groups_members")
          .where("group_id", isEqualTo: idRoom)
          .where("status_id",isEqualTo: 1)
          .get();

      if (querySnap.docs.isEmpty) {
        print("khong co thanh vien nao ca");
        return [];
      }

      // SỬA Ở ĐÂY: Map để lấy ra 'user_id' (String) thay vì đối tượng Users
      List<String?> listUserIDs = querySnap.docs.map((doc) {
        return doc.data()['user_id'] as String?;
      }).toList();

      return listUserIDs;
    } catch (e) {
      print("loi khi lay du lieu thanh vien cua nhom: $e");
      return [];
    }
  }
}
