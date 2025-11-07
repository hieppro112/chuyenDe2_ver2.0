import 'package:flutter/material.dart';
import 'package:giao_tiep_sv_user/Data/Users.dart';
import 'package:giao_tiep_sv_user/Data/room_chat.dart';

class CustomChatMember extends StatefulWidget {
  final String id_chat;
  final ChatRoom userInfo;
  final String content;
  final bool isnew;
  final ValueChanged ontap;
  const CustomChatMember({super.key, required this.content, required this.isnew, required this.id_chat, required this.ontap, required this.userInfo});

  @override
  State<CustomChatMember> createState() => _CustomChatMemberState();
}

class _CustomChatMemberState extends State<CustomChatMember> {
  @override
  Widget build(BuildContext context) {
    final name = widget.userInfo.name.toString();
    print("name $name");
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
      padding: EdgeInsets.symmetric(horizontal: 20,vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.black,width: 1)
      ),
      child: createMember(),

    );
  }

  Widget createMember(){
    return InkWell(
      onTap: () {
        return widget.ontap?.call(widget.id_chat);
      },
      child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            ClipOval(
              child: Image.network(widget.userInfo.avatarUrl,width: 45,height: 45,),
            ),
            SizedBox(width: 10,),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                Text(widget.userInfo.name,style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold
                ),),
                Text(widget.content,style: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                ),)
              ],
            )
          ],
        ),

        //update status new or old
        Icon(Icons.circle,size: 10,
        color: (widget.isnew==true)?Colors.blue:Colors.red,)
      ],
    ),
    );
  }
}