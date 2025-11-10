import 'package:flutter/material.dart';
import 'package:giao_tiep_sv_user/Data/Users.dart';
import 'package:giao_tiep_sv_user/Data/room_chat.dart';

class HeaderMessage extends StatelessWidget {
  final ChatRoom myInfo;
  const HeaderMessage({super.key, required this.myInfo, });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 25,vertical: 10),

      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(
          color: Colors.grey,
          width: 2
        ))
      ),

      child: createHeader(context),
    );
  }

  Widget createHeader(BuildContext context){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: ClipOval(
            child: Image.asset("assets/icons/ic_back.png",fit: BoxFit.cover,width: 30,height: 30,),
          ),
        ),

        Row(
          children: [
            Text(myInfo.name,
            overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),),

      SizedBox(width: 10,),

        InkWell(
          onTap: () {
            print("avatar");
          },
          child: ClipOval(
            child: Image.network(myInfo.avatarUrl,fit: BoxFit.cover,width: 45,height: 45,),
          ),
        ),
          ],
        )
        
      ],
    );
  }
}