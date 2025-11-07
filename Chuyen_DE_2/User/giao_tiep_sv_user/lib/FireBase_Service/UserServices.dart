import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:giao_tiep_sv_user/Data/Users.dart';

class Userservices {
  final FirebaseFirestore userDB = FirebaseFirestore.instance;

  Future<Users?> getUserForID(String myID)async{
    try{
      final snap = await userDB.collection("Users").doc(myID.trim()).get();
      print("my ${snap}");

      if(!snap.exists){
        print("khong co gia tri");
          return null;
      }
      // print("my ${Users.fromMap(snap.data()!)}");
      return Users.fromMap(snap.data()!);
    }catch(e){
        print("loi dl: $e");
        return null;
    }
  }
}