// notify_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> loadTypeZeroNotifications() async {
    try {
      final notificationsSnapshot = await _firestore
          .collection('Notifycations')
          .where('type_notify', isEqualTo: 0)
          .get();

      final List<Map<String, dynamic>> loadedNotifications =
          notificationsSnapshot.docs.map((doc) {
            final data = doc.data();

            return {
              'id': doc.id,
              'content': data['content'] ?? 'Không có nội dung',
              'title': data['title'] ?? 'Thông báo mới',
              'type_notify': data['type_notify'],
              'user_recipient_id':
                  data['user_recipient_id'] ?? 'Không rõ người nhận',
            };
          }).toList();

      return loadedNotifications;
    } catch (e) {
      print('Lỗi tải thông báo: $e');
      return [];
    }
  }
}
