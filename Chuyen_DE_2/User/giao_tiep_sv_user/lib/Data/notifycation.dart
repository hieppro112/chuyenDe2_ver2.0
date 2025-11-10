import 'package:cloud_firestore/cloud_firestore.dart';

class Notifycation {
  final String id;
  final String title;
  final String content;
  final int type_notify;
  final Map<String, String> user_recipient_ID; // Map<userId, name>

  Notifycation({
    required this.id,
    required this.title,
    required this.content,
    required this.type_notify,
    required this.user_recipient_ID,
  });

  factory Notifycation.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Notifycation(
      id: doc.id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      type_notify: data['type_notify'] ?? 0,
      user_recipient_ID: _parseRecipientMap(data['user_recipient_id']),
    );
  }

  // Hàm parse an toàn cho Map
  static Map<String, String> _parseRecipientMap(dynamic input) {
    if (input is Map) {
      return input.map((key, value) => MapEntry(key.toString(), value.toString()));
    }
    return {};
  }
}