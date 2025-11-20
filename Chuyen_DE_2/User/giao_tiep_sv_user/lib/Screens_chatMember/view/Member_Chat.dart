import 'package:flutter/material.dart';
import 'package:giao_tiep_sv_user/Screens_chatMember/widget/featchMemberChat.dart';

class ShowMemberChat extends StatefulWidget {
  final String idRoom;
  const ShowMemberChat({super.key, required this.idRoom});

  @override
  State<ShowMemberChat> createState() => _ShowMemberChatState();
}

class _ShowMemberChatState extends State<ShowMemberChat> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("Thành viên",style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold
        ),),
        centerTitle: true,
      ),
      body: Featchmemberchat(idRoomChat:widget.idRoom ),
    );
  }
}