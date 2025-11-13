import 'package:flutter/material.dart';
import 'package:giao_tiep_sv_user/Data/Users.dart';
import 'package:giao_tiep_sv_user/Data/room_chat.dart';
import 'package:giao_tiep_sv_user/FireBase_Service/UserServices.dart';

class CustomChatMember extends StatefulWidget {
  // final String id_chat;
  final String myid;
  final ChatRoom userInfo;
  final String content;
  final bool isnew;
  final ValueChanged ontap;
  const CustomChatMember({
    super.key,
    required this.content,
    required this.isnew,
    required this.ontap,
    required this.userInfo,
    required this.myid,
  });

  @override
  State<CustomChatMember> createState() => _CustomChatMemberState();
}

class _CustomChatMemberState extends State<CustomChatMember> {
  String URl_avt = "https://scontent.fsgn8-3.fna.fbcdn.net/v/t39.30808-6/581879330_1364467071710362_6849324345121571973_n.jpg?_nc_cat=1&ccb=1-7&_nc_sid=833d8c&_nc_ohc=sW1V4vrjsAkQ7kNvwEGXQgb&_nc_oc=AdlX1cN5uaux8BQHUCn5z5wmEnCw7oehPBWjP-8YDDnBTUUigtNyU9xpF1LD7unS14Q&_nc_zt=23&_nc_ht=scontent.fsgn8-3.fna&_nc_gid=Tx5AiTtAQ13I7mDFQO1qvQ&oh=00_AfgECX7XKYId_tyrq8kFbK4tY4MQW7o_N5cZ--C5u5imsQ&oe=691B9A13";
  String name_chat = "";
  final usDb = Userservices();

  @override void initState() {
    // TODO: implement initState
    super.initState();
    xulyNameandAVT();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.black, width: 1),
      ),
      child: createMember(),
    );
  }

  //lay thogn tin nguoi dung tu id
  Future<Users?> getInfoUser(String id) async {
    return await usDb.getUserForID(id);
  }

  //xu ky avt va name cho nhom va ca nhan 1-1
  void xulyNameandAVT() async {
    if (widget.userInfo.typeId == 1) {
      URl_avt = widget.userInfo.avatarUrl;
      name_chat = widget.userInfo.name;
    } else if (widget.userInfo.typeId == 0) {
      for (var item in widget.userInfo.users) {

        if (!item.trim().toLowerCase().contains(widget.myid)) {
          print("thang id ${widget.myid}");
          var user = await getInfoUser(item);
          URl_avt = user!.url_avt;
          name_chat = user!.fullname;
        }
      }

      // print("get us: ${user!.fullname.toString()}");
    }
  }

  Widget createMember() {
    xulyNameandAVT();
    return InkWell(
      onTap: () {
        return widget.ontap?.call(widget.userInfo.roomId);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              ClipOval(
                child: Image.network(
                  URl_avt,
                  width: 45,
                  height: 45,
                ),
              ),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name_chat,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    widget.content,
                    style: TextStyle(color: Colors.black, fontSize: 14),
                  ),
                ],
              ),
            ],
          ),

          //update status new or old
          Icon(
            Icons.circle,
            size: 10,
            color: (widget.isnew == true) ? Colors.blue : Colors.red,
          ),
        ],
      ),
    );
  }
}
