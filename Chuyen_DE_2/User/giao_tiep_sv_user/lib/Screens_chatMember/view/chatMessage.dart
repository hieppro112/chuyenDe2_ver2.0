import 'package:flutter/material.dart';
import 'package:giao_tiep_sv_user/Data/message.dart';
import 'package:giao_tiep_sv_user/Screens_chatMember/widget/customMessage.dart';
import 'package:giao_tiep_sv_user/Screens_chatMember/widget/custom_sender_message.dart';
import 'package:giao_tiep_sv_user/Screens_chatMember/widget/header_Message.dart';

class ScreenMessage extends StatefulWidget {
  const ScreenMessage({super.key});

  @override
  State<ScreenMessage> createState() => ScreenMessageState();
}

class ScreenMessageState extends State<ScreenMessage> {
  //avatar me
  String url_avt_me = "assets/images/avatar.png";

  List<message> listMessage = [
    message(
      id_message: "a",
      chat_id: "a1",
      sender_id: "23211TT3598@mail.tdc.edu.vn",
      content:
          "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam vel augue vitae lectus dictum ultricies. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae; Donec rutrum, nibh eget bibendum aliquet, elit sapien luctus lectus, id accumsan nulla massa a odio. ",
      create_at: DateTime.now(),
    ),
    message(
      id_message: "a",
      chat_id: "a1",
      sender_id: "23211TT3598@mail.tdc.edu.vn",
      content: "hello cac ban ",
      create_at: DateTime.now(),
    ),
    message(
      id_message: "a",
      chat_id: "a1",
      sender_id: "23211TT3598@mail.tdc.edu.vn",
      content: "hello cac ban ",
      create_at: DateTime.now(),
    ),
    message(
      id_message: "a",
      chat_id: "a1",
      sender_id: "23211TT3598@mail.tdc.edu.vn",
      content:
          "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam vel augue vitae lectus dictum ultricies. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae; Donec rutrum, nibh eget bibendum aliquet, elit sapien luctus lectus, id accumsan nulla massa a odio. ",
      create_at: DateTime.now(),
    ),
    message(
      id_message: "a",
      chat_id: "a1",
      sender_id: "23211TT3598@mail.tdc.edu.vn",
      content: "hello cac ban ",
      create_at: DateTime.now(),
    ),
    message(
      id_message: "a",
      chat_id: "a1",
      sender_id: "23211TT3598@mail.tdc.edu.vn",
      content: "hello cac ban ",
      create_at: DateTime.now(),
    ),
    message(
      id_message: "a",
      chat_id: "a1",
      sender_id: "23211TT3598@mail.tdc.edu.vn",
      content: "hello cac ban ",
      create_at: DateTime.now(),
    ),
    message(
      id_message: "a",
      chat_id: "a1",
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

            SafeArea(
              child: CustomSenderMessage(
                onSelectedImage: (value) {
                  if (value != null) {
                    message messImg = message(
                      id_message: "",
                      chat_id: "",
                      sender_id: "",
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
                    chat_id: "a1",
                    sender_id: "23211TT3598@mail.tdc.edu.vn",
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
            ),
          ],
        ),
      ),
    );
  }

  Widget createListMessage() {
    return ListView.builder(
      controller: _scrollController,
      shrinkWrap: true,
      itemCount: listMessage.length,
      itemBuilder: (context, index) {
        var value = listMessage[index];
        return Custommessage(
          forme_sender: true,
          url_avt: url_avt_me,
          content: value.content!,
          Url_media: value.media_url,
        );
      },
    );
  }

  Widget Header() {
    return HeaderMessage(
      fullname: "Le Dai Hiep",
      url_avt: "assets/images/avatar.png",
    );
  }

  //message
  // Widget Message() {
  //   return Custommessage(
  //     forme_sender: false,
  //     url_avt: "assets/images/avatar.png",
  //     content: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam vel augue vitae lectus dictum ultricies. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae; Donec rutrum, nibh eget bibendum aliquet, elit sapien luctus lectus, id accumsan nulla massa a odio.",
  //   );
  // }
}
