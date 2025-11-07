import 'dart:io';

import 'package:flutter/material.dart';

class Custommessage extends StatelessWidget {
  final bool forme_sender;
  final String url_avt;
  final String content;
  final String? Url_media;

  const Custommessage({
    super.key,
    required this.forme_sender,
    required this.url_avt,
    required this.content,
    this.Url_media,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: createMessage(),
    );
  }

  Widget createMessage() {
    //khi người khác gửi tin nhắn
    if (forme_sender == false) {
      return Row(
        children: [
          ClipOval(
            child: Image.network(
              url_avt,
              fit: BoxFit.cover,
              height: 35,
              width: 35,
            ),
          ),
          SizedBox(width: 10),
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  if (content.isNotEmpty)
                    Text(
                      content,
                      style: TextStyle(fontSize: 14),
                      softWrap: true,
                    ),
                  if (Url_media != null && Url_media!.isNotEmpty) ...[
                    SizedBox(height: 8),
                    Image.file(File(Url_media!), width: 150, fit: BoxFit.cover),
                  ],
                ],
              ),
            ),
          ),
        ],
      );
    } // khi bản thân gui tin nhan
    else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  if (content.isNotEmpty)
                    Text(
                      content,
                      style: TextStyle(fontSize: 14),
                      softWrap: true,
                    ),
                  if (Url_media != null && Url_media!.isNotEmpty) ...[
                    SizedBox(height: 8),
                    Image.file(
                      File(Url_media!),
                      // width: 150,
                      fit: BoxFit.cover,
                    ),
                  ],
                ],
              ),
            ),
          ),

          SizedBox(width: 10),
          ClipOval(
            child: Image.network(
              url_avt,
              fit: BoxFit.cover,
              height: 35,
              width: 35,
            ),
          ),
        ],
      );
    }
  }
}
