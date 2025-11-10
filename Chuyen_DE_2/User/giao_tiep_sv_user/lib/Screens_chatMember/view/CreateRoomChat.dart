import 'package:flutter/material.dart';
import 'package:giao_tiep_sv_user/Data/Users.dart';
import 'package:giao_tiep_sv_user/Data/room_chat.dart';
import 'package:giao_tiep_sv_user/Screens_chatMember/FirebaseStore/MessageService.dart';
import 'package:giao_tiep_sv_user/Screens_chatMember/widget/pickedMemberChat.dart';
import 'package:giao_tiep_sv_user/Widget/MyButton.dart';
import 'package:uuid/uuid.dart';

class CreateRoomChat extends StatefulWidget {
  final String myId;
  const CreateRoomChat({super.key, required this.myId});

  @override
  State<CreateRoomChat> createState() => _CreateRoomChatState();
}

class _CreateRoomChatState extends State<CreateRoomChat> {
  //khai bao servies
  final messService = MessageService();
    List<Users> listSelected_uyquyen = [];
    List<String> listIDUser = [];
    String id = Uuid().v4();
  TextEditingController nameChat = TextEditingController();
  
  @override void initState() {
    // TODO: implement initState
    super.initState();
    getIDUser();
    print("list id : ${listIDUser.length}");
  }
  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("Tạo cuộc trò chuyện",style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold
        ),),
        centerTitle: true,
      ),


      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 20,vertical: 10),
        child: Column(
          children: [
            createNameGroup(),
            SizedBox(height: 20,),
            createButton(),
            SizedBox(height: 20,),
            createConfirm(ChatRoom(roomId: id, lastMessage: "", lastSender: "", lastTime: DateTime.now(), users: listIDUser, name: nameChat.text, avatarUrl: "https://wallpapers.com/images/hd/football-players-hd-ronaldo-real-madrid-2x3lm9waylolretc.jpg", typeId: 0, createdBy: widget.myId, createdAt: DateTime.now())),
          ],
        ),
      ),
    );
  }

  //lay id trong danh sach nguoi dung
Future<List<String>> getIDUser() async {

  for (var element in listSelected_uyquyen) {
    listIDUser.add(element.id_user);
  }

  return listIDUser;
}

  //create name group
  Widget createNameGroup() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Tên nhóm chat:", style: TextStyle(fontSize: 25)),
        SizedBox(height: 5),
        TextField(
          controller: nameChat,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.lightBlueAccent),
            ),
            //border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  //chon nguoi nhan 
   Widget createButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Mybutton(
          url_icon: 'assets/images/user.png',
          nameButton: "Chọn người",
          Mycolor: Colors.white,
          ontap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Pickedmemberchat(
                throwss: 2,
                GetList: (value) {
                  setState(() {
                    listSelected_uyquyen = value;
                    getIDUser();
                    print("list id: ${listSelected_uyquyen.length} - ${listIDUser.length}");
                  });
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

//nut xac nhan tao nhom chat
  Widget createConfirm(ChatRoom chatroom){
    return InkWell(
      onTap: () {
        messService.createChatRooms(chatroom);
        Navigator.pop(context);
      },
      child: Container(
        decoration: BoxDecoration(
          color:Colors.lightBlueAccent,
          borderRadius: BorderRadius.circular(20)
        ),
        margin: EdgeInsets.symmetric(horizontal: 15),
        padding: EdgeInsets.symmetric(horizontal: 15,vertical: 10),
        child: Text("Xác nhận", style: TextStyle(
          color: Colors.white,
          fontSize: 19
        ),),
      ),
    );
}
}