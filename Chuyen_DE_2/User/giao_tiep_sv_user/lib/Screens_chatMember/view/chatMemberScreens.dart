import 'package:flutter/material.dart';
import 'package:giao_tiep_sv_user/Data/room_chat.dart';
import 'package:giao_tiep_sv_user/Screen_member_group/widget/customSearch.dart';
import 'package:giao_tiep_sv_user/Screens_chatMember/view/chatMessage.dart';
import 'package:giao_tiep_sv_user/Screens_chatMember/widget/custom_chat_member.dart';
import 'package:giao_tiep_sv_user/ThongBao/ManHinhThongBao.dart';
import 'package:giao_tiep_sv_user/Widget/MyButton.dart';
import 'package:giao_tiep_sv_user/Widget/headerWidget.dart';

class ChatMemberScreen extends StatefulWidget {
  const ChatMemberScreen({super.key});

  @override
  State<ChatMemberScreen> createState() => _ChatMemberScreenState();
}

class _ChatMemberScreenState extends State<ChatMemberScreen> {
  List<Room_chat> listMessage = [
    Room_chat(
      room_id: "0",
      type_id: 0,
      name: "Le Dinh Thuan",
      avt_url: "assets/images/user.png",
      created_id: 0,
      create_at: DateTime.now(),
    ),
    Room_chat(
      room_id: "0",
      type_id: 0,
      name: "Pham Thắng",
      avt_url: "assets/images/user.png",
      created_id: 0,
      create_at: DateTime.now(),
    ),
    Room_chat(
      room_id: "0",
      type_id: 0,
      name: "Lê Đại Hiệp",
      avt_url: "assets/images/user.png",
      created_id: 0,
      create_at: DateTime.now(),
    ),
    Room_chat(
      room_id: "0",
      type_id: 0,
      name: "Cao Quang Khánh",
      avt_url: "assets/images/user.png",
      created_id: 0,
      create_at: DateTime.now(),
    ),
    Room_chat(
      room_id: "0",
      type_id: 0,
      name: "Le Dinh Thuan",
      avt_url: "assets/images/user.png",
      created_id: 0,
      create_at: DateTime.now(),
    ),
    Room_chat(
      room_id: "0",
      type_id: 0,
      name: "Le Dinh Thuan",
      avt_url: "assets/images/user.png",
      created_id: 0,
      create_at: DateTime.now(),
    ),
    Room_chat(
      room_id: "0",
      type_id: 1,
      name: "Trò chuyện IT",
      avt_url: "assets/images/user.png",
      created_id: 0,
      create_at: DateTime.now(),
    ),
    Room_chat(
      room_id: "0",
      type_id: 1,
      name: "Trò chuyện IT",
      avt_url: "assets/images/user.png",
      created_id: 0,
      create_at: DateTime.now(),
    ),
    Room_chat(
      room_id: "0",
      type_id: 1,
      name: "Cùng học java",
      avt_url: "assets/images/user.png",
      created_id: 0,
      create_at: DateTime.now(),
    ),
    Room_chat(
      room_id: "0",
      type_id: 1,
      name: "chia sẻ tài liệu flutter",
      avt_url: "assets/images/user.png",
      created_id: 0,
      create_at: DateTime.now(),
    ),
  ];
  double width = 0;
  bool ischatGroup = false;
  List<Room_chat> listMessageSearch = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    listMessageSearch = listMessage;
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        // child: SingleChildScrollView(
        child: Column(
          children: [
            //header
            Headerwidget(
              url_avt: "assets/images/avatar.png",
              fullname: "Le Dai Hiep",
              email: "23211TT3598@gmail.com",
              width: width.toDouble(),
              chucnang: IconButton(
                onPressed: () {
                  // print("notifycation");
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ManHinhThongBao(),));
                },
                icon: Icon(Icons.notifications, color: Colors.amber, size: 45),
              ),
            ),
            //search Message
            SizedBox(height: 8),
            createSearchMessage(),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: createButtonMessage(),
            ),

            //2 button bạn bè và nhóm

            //danh sach tin nhắn
            Expanded(child: createListMessage()),
          ],
        ),
      ),
    );
    // );
  }

  //create listview message
  Widget createListMessage() {
    String content = "xin chào bạn";
    bool isnew = true;
    return ListView.builder(
      shrinkWrap: true,
      itemCount: listMessageSearch.length,
      itemBuilder: (context, index) {
        var value = listMessageSearch[index];
        return CustomChatMember(
          id_chat: "hiep",
          url_avt: value.avt_url,
          fullname: value.name,
          content: content,
          isnew: isnew,
          ontap: (value) {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return ScreenMessage();
            },));
          },
        );
      },
    );
  }

  Widget createButtonMessage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Mybutton(
          Mycolor: Color(0xffecf3e5),
          url_icon: "assets/icons/ic_friend.png",
          nameButton: "Bạn bè",
          ontap: () {
            setState(() {
              ischatGroup = false;
              listMessageSearch = listMessage.where((element) {
                return element.type_id == 0;
              }).toList();
            });
          },
        ),
        Mybutton(
          Mycolor: Color(0xffffe5e5),
          url_icon: "assets/icons/ic_group.png",
          nameButton: "Nhóm",
          ontap: () {
            setState(() {
              ischatGroup = true;
              listMessageSearch = listMessage.where((element) {
                return element.type_id == 1;
              }).toList();
            });
          },
        ),
      ],
    );
  }

  Widget createSearchMessage() {
    return Customsearch(
      onTap: (value) {
        if (ischatGroup == false) {
          setState(() {
            listMessageSearch = listMessage.where((element) {
              return element.name.toLowerCase().contains(value.toLowerCase()) &&
                  element.type_id == 0;
            }).toList();
          });
        } else {
          setState(() {
            listMessageSearch = listMessage.where((element) {
              return element.name.toLowerCase().contains(value.toLowerCase()) &&
                  element.type_id == 1;
            }).toList();
          });
        }
      },
    );
  }
}
