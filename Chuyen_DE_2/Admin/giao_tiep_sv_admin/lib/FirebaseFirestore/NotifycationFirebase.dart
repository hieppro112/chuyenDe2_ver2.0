import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:giao_tiep_sv_admin/Data/Notifycation.dart';

class Notifycationfirebase {
  final FirebaseFirestore notiDb = FirebaseFirestore.instance;
  Future<void> createNotifycation(Notifycation notify)async{
    try{
      await notiDb.collection("Notifycations").doc(notify.id).set(notify.tomap());
    }
    catch(e){
      print("loi $e");
      rethrow;
    }

  }
}