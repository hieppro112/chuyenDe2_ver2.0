import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:giao_tiep_sv_user/Data/Users.dart';
import 'package:giao_tiep_sv_user/Data/room_chat.dart';
import 'package:giao_tiep_sv_user/FireBase_Service/UserServices.dart';
import 'package:giao_tiep_sv_user/Screen_member_group/widget/customSearch.dart';
import 'package:giao_tiep_sv_user/Screens_chatMember/FirebaseStore/MessageService.dart';
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
  final MessageService messService = MessageService();
  final Userservices userService = Userservices();
  bool isload = false;
  List<ChatRoom> listMessage = [];
  double width = 0;
  bool ischatGroup = false;
  List<ChatRoom> listMessageSearch = [];
  late final Uid;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.email != null) {
      Uid = user.email!.split("@")[0];
      print("My UID: $Uid");

      // Sau khi có UID thì gọi hàm lấy dữ liệu
      FeatchDataListChats(Uid);
    } else {
      print("⚠️ User chưa đăng nhập!");
    }
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
            createHeader(Uid.toString()),
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

  //get user tu id
  Future<Users?> fetchIdUs(String myId) {
    return userService.getUserForID(myId);
  }

  //lay dl dua vao list
  Future<void> FeatchDataListChats(String Uid) async {
    isload = true;
    final listChats = await messService.listChat(Uid);
    print("leng listChat: ${listChats.length}");
    if (mounted) {
      setState(() {
        listMessage = listChats;
        listMessageSearch = listMessage;
        isload = false;
      });
    }
  }

  //custom header
  Widget createHeader(String myId) {
    return FutureBuilder<Users?>(
      future: fetchIdUs(myId.toUpperCase()),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Text('Lỗi: ${snapshot.error}');
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const Text('Không tìm thấy user');
        }

        final user = snapshot.data!;

        return Headerwidget(
          myUs: user,
          width: width.toDouble(),
          chucnang: IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    ManHinhThongBao(currentUser: user), 
              ),
            ),
            icon: const Icon(
              Icons.notifications,
              color: Colors.amber,
              size: 45,
            ),
          ),
        );
      },
    );
  }

  //create listview message
  Widget createListMessage() {
    // String content = "xin chào bạn";
    bool isnew = true;
    return (isload == true)
        ? Center(child: CircularProgressIndicator())
        : ListView.builder(
            shrinkWrap: true,
            itemCount: listMessageSearch.length,
            itemBuilder: (context, index) {
              var value = listMessageSearch[index];
              return CustomChatMember(
                userInfo: value,
                id_chat: value.roomId,
                content: value.lastMessage,
                isnew: isnew,
                ontap: (valueTap) {
                  //value tap tra ve id phong da nhan vao
                  //chuyen sang man hinh nhan tin
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return ScreenMessage(
                          myId: Uid.toString(),
                          sender_to: ChatRoom(
                            roomId: "1",
                            lastMessage: "hello ban hien",
                            lastSender: "23211tt3598",
                            lastTime: DateTime.now(),
                            users: ["23211tt3598", "23211tt3599"],
                            name: "Le van nam",
                            createdAt: DateTime.now(),
                            avatarUrl:
                                "https://img-s-msn-com.akamaized.net/tenant/amp/entityid/AA1PSSTd.img?w=730&h=486&m=6&x=27&y=208&s=422&d=193",
                            createdBy: "23211tt3598",
                            typeId: 0,
                          ),
                          idRoom: valueTap,
                        );
                      },
                    ),
                  );

                  print("room john: ${valueTap}");
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
                return element.typeId == 0;
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
                return element.typeId == 1;
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
                  element.typeId == 0;
            }).toList();
          });
        } else {
          setState(() {
            listMessageSearch = listMessage.where((element) {
              return element.name.toLowerCase().contains(value.toLowerCase()) &&
                  element.typeId == 1;
            }).toList();
          });
        }
      },
    );
  }
}
