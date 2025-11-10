import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:giao_tiep_sv_user/Data/Notifycation.dart';

class Notifycationfirebase {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Notifycation>> getAllNotifycation() {
    return _firestore
        .collection('Notifycations')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Notifycation.fromFirestore(doc)).toList();
    });
  }
}
