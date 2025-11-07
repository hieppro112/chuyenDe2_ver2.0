import 'package:flutter/material.dart';
import 'package:giao_tiep_sv_user/Data/message.dart';
import 'package:giao_tiep_sv_user/Data/room_chat.dart';
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
  //avatar me
  String url_avt_me = "https://media-cdn-v2.laodong.vn/Storage/NewsPortal/2021/10/30/969136/Cristiano-Ronaldo4.jpg";

  List<message> listMessage = [
    message(
      id_message: "a",
      sender_id: "23211TT3598@mail.tdc.edu.vn",
      content: "hello cac ban ",
      create_at: DateTime.now(),
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
                    message messImg = message(
                      id_message: "",
                      sender_id: myId,
                      content: "",
                      media_url: value.path,
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
                  
                  message newValue = message(
                    id_message: "a",
                    sender_id: myId,
                    content: value,
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
//hien thi list tin nhan 
  Widget createListMessage() {
    return 
    (widget.idRoom=="23211tt3598")?
    ListView.builder(
      controller: _scrollController,
      shrinkWrap: true,
      itemCount: listMessage.length,
      itemBuilder: (context, index) {
        var value = listMessage[index];
        return Custommessage(
          forme_sender: (value.sender_id==widget.myId),
          url_avt: url_avt_me,
          content: value.content!,
          Url_media: value.media_url,
        );
      },
    )
    :Center(child: Text("hello"),);
  }

  Widget Header() {
    return HeaderMessage(
      myInfo: widget.sender_to,
    );
  }
}
