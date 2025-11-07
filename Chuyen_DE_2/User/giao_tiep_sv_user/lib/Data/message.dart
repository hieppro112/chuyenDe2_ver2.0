import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String id_message;
  // final String chat_id;
  final String sender_id;
  final String? content;
  final String? media_url;
  final DateTime create_at;
  final bool isread;

  Message({
    required this.isread,
    required this.id_message,
    required this.sender_id,
    this.content,
    this.media_url,
    required this.create_at,
  });

  //doc du lieu
  factory Message.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Message(
      isread: data['isRead'] ?? false,
      id_message: doc.id,
      sender_id: data['sender_id'] ?? "no id",
      create_at: (data['create_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      content: data['content'] ?? "no conten",
      media_url:
          data['media_url'] ??
          "",
    );
  }

  //dua du lieu len firebase
  Map<String,dynamic> toMap(){
    return{
      'sender_id':id_message,
      'content':content,
      'media_url':media_url,
      'isRead':isread,
      'create_at':Timestamp.fromDate(create_at),
      'sender_id':sender_id
    };
  }
}
