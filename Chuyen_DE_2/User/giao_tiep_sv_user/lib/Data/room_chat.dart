import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoom {
  final String roomId;        
  final String lastMessage;   
  final String lastSender;    
  final DateTime lastTime;    
  final List<String> users;   
  final String name;          // Tên nhóm / tên cuộc trò chuyện
  final String avatarUrl;     // Ảnh nhóm hoặc người chat cùng
  final int typeId;           // 0: 1-1, 1: nhóm
  final String createdBy;     // ID người tạo
  final DateTime createdAt;   // Thời gian tạo

  ChatRoom({
    required this.roomId,
    required this.lastMessage,
    required this.lastSender,
    required this.lastTime,
    required this.users,
    required this.name,
    required this.avatarUrl,
    required this.typeId,
    required this.createdBy,
    required this.createdAt,
  });

  factory ChatRoom.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return ChatRoom(
      roomId: doc.id,
      lastMessage: data['lastMessage'] ?? '',
      lastSender: data['lastSender'] ?? '',
      lastTime: (data['lastTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      users: List<String>.from(data['users'] ?? []),
      name: data['name'] ?? '',
      avatarUrl: data['avatarUrl'] ?? 'https://img-s-msn-com.akamaized.net/tenant/amp/entityid/AA1PSSTd.img?w=730&h=486&m=6&x=27&y=208&s=422&d=193',
      typeId: data['typeId'] ?? 0,
      createdBy: data['createdBy'] ?? '',
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'lastMessage': lastMessage,
      'lastSender': lastSender,
      'lastTime': Timestamp.fromDate(lastTime),
      'users': users,
      'name': name,
      'avatarUrl': avatarUrl,
      'typeId': (users.length>2)?1:0,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
