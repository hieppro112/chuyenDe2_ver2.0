import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:giao_tiep_sv_user/Data/Notifycation.dart';

class Notifycationfirebase {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 🔥 Lấy danh sách thông báo (realtime)
  Stream<List<Notifycation>> getAllNotifycation() {
    return _firestore
        .collection('Notifycations')
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Notifycation.fromFirestore(doc);
      }).toList();
    });
  }

  /// 📩 Lấy thông báo dành riêng cho người dùng có id cụ thể
  Stream<List<Notifycation>> getNotifycationForUser(String userId) {
    return _firestore
        .collection('Notifycations')
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final notify = Notifycation.fromFirestore(doc);
        // chỉ lấy thông báo mà user_recipient_ID có chứa userId
        if (notify.user_recipient_ID.containsKey(userId)) {
          return notify;
        }
        return null;
      }).whereType<Notifycation>().toList();
    });
  }
}
