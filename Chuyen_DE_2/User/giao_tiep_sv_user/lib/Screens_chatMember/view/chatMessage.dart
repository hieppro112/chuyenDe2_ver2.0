import 'package:flutter/material.dart';
import 'package:giao_tiep_sv_user/Data/message.dart';
import 'package:giao_tiep_sv_user/Data/room_chat.dart';
import 'package:giao_tiep_sv_user/Screens_chatMember/FirebaseStore/MessageService.dart';
import 'package:giao_tiep_sv_user/Screens_chatMember/widget/customMessage.dart';
import 'package:giao_tiep_sv_user/Screens_chatMember/widget/custom_sender_message.dart';
import 'package:giao_tiep_sv_user/Screens_chatMember/widget/header_Message.dart';

class ScreenMessage extends StatefulWidget {
  final String myId;
  final ChatRoom sender_to;
  final String idRoom;
  const ScreenMessage({super.key, required this.sender_to, required this.idRoom, required this.myId});

  @override
  State<ScreenMessage> createState() => ScreenMessageState();
}

class ScreenMessageState extends State<ScreenMessage> {
  //khai báo service
  final messageService = MessageService();
  //avatar me
  String url_avt_me = "https://media-cdn-v2.laodong.vn/Storage/NewsPortal/2021/10/30/969136/Cristiano-Ronaldo4.jpg";

  List<Message> listMessage = [
    Message(
      id_message: "a",
      sender_id: "23211TT3598@mail.tdc.edu.vn",
      content: "hello cac ban ",
      create_at: DateTime.now(),
      isread: false,
    ),
  ];

//chuyen dong man hinh xuong ben duoi
  final ScrollController _scrollController = ScrollController();
  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
         _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }


@override void initState() {
    // TODO: implement initState
    super.initState();
    _scrollToBottom();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Color(0xfff5f5f5),
      body: SafeArea(
        child: Column(
          children: [
            Header(),
            Expanded(child: createListMessage()),
            create(widget.myId.toString()),
            
          
          ],
        ),
      ),
    );
  }
  //
  Widget create(String myId){
    return SafeArea(
              child: CustomSenderMessage(
                onSelectedImage: (value) {
                  if (value != null) {
                    Message messImg = Message(
                      id_message: "",
                      sender_id: myId,
                      content: "",
                      media_url: value.path,
                      isread: true,
                      create_at: DateTime.now(),
                    );
                    setState(() {
                      listMessage.add(messImg);
                    });
                    _scrollToBottom();
                    print(value.path);
                  }
                },
                onTapSend: (value) {
                  
                  Message newValue = Message(
                    id_message: "a",
                    sender_id: myId,
                    content: value,
                    isread: true,
                    create_at: DateTime.now(),
                  );
                  setState(() {
                    listMessage.add(newValue);
                    print(listMessage.length);
                  });
                  _scrollToBottom();
                },
              ),
            );
          
  }

  //lay dl cho dl chat
  
//hien thi list tin nhan 
  Widget createListMessage() {

    //lay avt nguoi dung 
    return StreamBuilder(stream: messageService.streamMessage(widget.idRoom), 
    builder: (context, snapshot) {
      //doi load dl
      if(snapshot.connectionState == ConnectionState.waiting){
        return Center(child: CircularProgressIndicator(
          color: Colors.blue,
        ),);
      }

      if(!snapshot.hasData||snapshot.data!.isEmpty){
        return Center(child: Text("Chưa có tin nhắn nào"),);
      }

      final lisstMessage = snapshot.data!;
      return ListView.builder(
      controller: _scrollController,
      shrinkWrap: true,
      itemCount: lisstMessage.length,
      reverse: false,
      itemBuilder: (context, index) {
        var value = lisstMessage[index];
        return Custommessage(
          forme_sender: (value.sender_id==widget.myId),
          url_avt: "https://wallpapercave.com/wp/wp11591001.jpg",
          content: value.content??"",
          Url_media: value.media_url??"",
        );
      },
    );


    },);
  }

  Widget Header() {
    return HeaderMessage(
      myInfo: widget.sender_to,
    );
  }
}
