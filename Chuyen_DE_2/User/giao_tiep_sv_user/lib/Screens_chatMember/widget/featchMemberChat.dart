import 'package:flutter/material.dart';
import 'package:giao_tiep_sv_user/Data/Users.dart';
import 'package:giao_tiep_sv_user/FireBase_Service/UserServices.dart';
import 'package:giao_tiep_sv_user/Screens_chatMember/FirebaseStore/MessageService.dart';

class Featchmemberchat extends StatefulWidget {
  final String idRoomChat;
  const Featchmemberchat({super.key, required this.idRoomChat});

  @override
  State<Featchmemberchat> createState() => _FeatchmemberchatState();
}

class _FeatchmemberchatState extends State<Featchmemberchat> {
  final messService = MessageService();
  final userService = Userservices();
  int lengthList = 0;
  List<Users?> users = [];
  @override
  Widget build(BuildContext context) {
    return listMember();
  }

  Widget listMember() {
    return StreamBuilder<List<String>>(
      stream: messService.getListIdUser(widget.idRoomChat),
      builder: (context, snapshot) {
        if(snapshot.connectionState == ConnectionState.waiting){
          return Center(child: CircularProgressIndicator(),);
        }
        if(snapshot.hasError){
          return Center(child: Text("Lỗi: ${snapshot.error}"),);
        }
        List<String> listId = [];
        listId = snapshot.data??[];

        return ListView.builder(
          itemCount: listId.length,
          itemBuilder: (context, index) {
          // Users member = getMember(listId[index]);
          return customMember(listId[index]);
        },);

      },
    );
  }

  Future<Users?> getMember(String idUser)async{
    return await userService.getUserForID(idUser);
  }

  

  // Widget customMember(Users member){
  //   //Users user = await userService.getUserForID(idUser);
    
  //   return InkWell(
  //     onTap: () {
     
  //     },
  //     child: Padding(
  //       padding: EdgeInsets.all(10),
  //       child: Row(
  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //         children: [
  //           Row(
  //             children: [
  //               //create img avatar
  //               ClipOval(
  //                 child: Image.network(
  //                   member.url_avt,
  //                   fit: BoxFit.fill,
  //                   height: 40,
  //                   width: 40,
  //                 ),
  //               ),
  //               SizedBox(width: 15),
  //               //name
  //               Text(
  //                 member.fullname,
  //                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
  //               ),
  //             ],
  //           ),

            
            
  //         ],
  //       ),
  //     ),
  //   );
  // }



Widget customMember(String idUser) {
  return FutureBuilder<Users?>(
    future: getMember(idUser),
    builder: (context, snapshot) {

      if (snapshot.connectionState == ConnectionState.waiting) {
        return Padding(
          padding: EdgeInsets.all(10),
          child: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 10),
              Text("Đang tải...")
            ],
          ),
        );
      }

      if (!snapshot.hasData) {
        return ListTile(
          title: Text("Không tải được user"),
        );
      }

      final member = snapshot.data!;

      return InkWell(
        onTap: () {},
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Row(
            children: [
              ClipOval(
                child: Image.network(
                  member.url_avt,
                  fit: BoxFit.cover,
                  width: 40,
                  height: 40,
                ),
              ),
              SizedBox(width: 15),
              Text(
                member.fullname,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      );
    },
  );
}

}
