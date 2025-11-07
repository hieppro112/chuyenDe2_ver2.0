import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:giao_tiep_sv_user/Data/message.dart';
import 'package:giao_tiep_sv_user/Data/room_chat.dart';

class MessageService {
  final FirebaseFirestore messDB = FirebaseFirestore.instance;

  //lay danh sách tin nhan
  Future<List<ChatRoom>> listChat(String myID) async {
    try {
      final querySnap = await messDB
          .collection("ChatRooms")
          .where("users", arrayContains: myID)
          .orderBy("lastTime", descending: true)
          .get();

      if (querySnap.docs.isEmpty) {
        print("Không có phòng chat nào cả");
        return [];
      }

      List<ChatRoom> roomsChat = querySnap.docs.map((e) {
        final data = e.data();
        data["roomId"] = e.id;
        return ChatRoom.fromFirestore(e);
      }).toList();

      return roomsChat;
    } catch (e) {
      print("Lỗi lấy danh sách chat: $e");
      return [];
    }
  }

  // Stream realtime để load lai danh sách tin nhắn
  Stream<List<ChatRoom>> streamChatRooms(String myID) {
    return messDB
        .collection("ChatRooms")
        .where("users", arrayContains: myID)
        .orderBy("lastTime", descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            data["roomId"] = doc.id;
            return ChatRoom.fromFirestore(doc);
          }).toList(),
        );
  }

  //stream real time load các tin nhắn
  Stream<List<Message>> streamMessage(String idRoomChat) {
    return messDB
        .collection("ChatRooms")
        .doc(idRoomChat)
        .collection("Message")
        .orderBy("create_at", descending: false)
        .snapshots()
        .map((event) {
          return event.docs.map((doc) {
            return Message.fromFirestore(doc);
          }).toList();
        });
  }

  //gui tin nhan
  Future<Message?> sendMessage({
    required String roomId,
    required String senderID,
    String? content,
    String? mediaUrl,
  }) async {
    try {
      final messRef = messDB
          .collection("ChatRooms")
          .doc(roomId)
          .collection("Message")
          .doc();
      final message = Message(
        isread: false,
        id_message: messRef.id,
        content:content??"null roi" ,
        sender_id: senderID,
        create_at: DateTime.now(),
      );

      await messRef.set(message.toMap());
      print("gui tin nhan thanh cong");

      //cap nhat lai phong chat
      await messDB.collection("ChatRooms").doc(roomId).update({
        "lastMessage":content??"",
        "lastTime":FieldValue.serverTimestamp(),
      });
      return message;

    } catch (e) {
      print("loi khi gui tin nhan $e");
      return null;
    }
  }
}
