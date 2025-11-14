import 'package:flutter/material.dart';
import 'package:giao_tiep_sv_user/Data/Users.dart';
import 'package:giao_tiep_sv_user/Data/groups_members.dart';
import 'package:giao_tiep_sv_user/FireBase_Service/UserServices.dart';
import 'package:giao_tiep_sv_user/FireBase_Service/group_service.dart';
import 'package:giao_tiep_sv_user/Screen_member_group/widget/customMember.dart';
import 'package:giao_tiep_sv_user/Screen_member_group/widget/customSearch.dart';
import 'package:giao_tiep_sv_user/maneger_member_group_Screens/serviceGroup/groupService.dart';

class AddMemberScreen extends StatefulWidget {
  final String groupID;
  final List<Users?> listMemberGroup;
  const AddMemberScreen({super.key, required this.listMemberGroup, required this.groupID});

  @override
  State<AddMemberScreen> createState() => _AddMemberScreenState();
}

class _AddMemberScreenState extends State<AddMemberScreen> {
  //khai bao serivce
  final groupService = GroupserviceManeger();
  final userDB = Userservices();
  bool isload = false;
  
  List<Users> Listsearch = [];
  List<Users> ListMember = [];

  //danh sach duoc chon
  List<String> listSelected =[];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Thêm thành viên",
          style: TextStyle(
            color: Color(0xffA72E2E),
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Image.asset(
              "assets/icons/ic_back.png",
              fit: BoxFit.contain,
              height: 15,
              width: 15,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //search member
            Customsearch(
              onTap: (value) {
                setState(() {
                  bool checkSearchMail = value.contains("@mail.tdc.edu.vn");
                  if (checkSearchMail == true) {
                    Listsearch = ListMember.where((element) {
                      // print("e: ${element.email}");
                      return element.email.toLowerCase().contains(
                        value.toLowerCase(),
                      );
                    }).toList();
                    print(Listsearch.length);
                  } else {
                    Listsearch = ListMember.where((element) {
                      return element.fullname.toLowerCase().contains(
                        value.toLowerCase(),
                      );
                    }).toList();
                  }
                });
              },
            ),
            SizedBox(height: 10),
            Text(
              "Kết quả:${Listsearch.length}",
              style: TextStyle(
                color: Colors.black.withOpacity(0.6),
                fontSize: 15,
              ),
            ),
            SizedBox(height: 10),
            Expanded(child: create_listMember(),)
          ],
        ),
      ),

      

      //nut them xac nhan
      floatingActionButton: FloatingActionButton(
        onPressed: () async{
          await addMemberGroup(listSelected);
          ScaffoldMessenger.of(context).showSnackBar(
            await SnackBar(
              content: Text('Đã thêm ${listSelected.length} thành viên vào nhóm !'),
              duration: Duration(seconds: 3),
            ),
          );
          Navigator.pop(context);
        },
        backgroundColor: Colors.blue,
        child: Icon(Icons.add),
      ),
    );
  }

  //them cac thanh vien duoc moi vao nhom
      Future<void> addMemberGroup(List<String> listUSAdd) async{
        for(var item in listUSAdd){
          var newValue = GroupMember(group_id: widget.groupID, user_id: item, role_id: 1, status_id: 0, joined_at: DateTime.now().toString());
          await groupService.addDataGroupMember(newValue);
        }
      }


//list user
  Widget create_listMember() {
    return (isload)?Center(child: CircularProgressIndicator(color: Colors.blue,),)
    :ListView.builder(
      shrinkWrap: true,
     // physics: NeverScrollableScrollPhysics(),
      itemCount: Listsearch.length,
      itemBuilder: (context, index) {
        var value = Listsearch[index];
        return CustommemberWidget(
          id: value.id_user,
          url: value.url_avt,
          fullname: value.fullname,
          ontap: (value) {
            print("${value!.idUser} - ${value!.picked}");
            if(value.picked==true){
              listSelected.add(value.idUser);
            }
            else{
              listSelected.removeWhere((element) {
                return element.trim().contains(value.idUser);
              },);
            }
          },
        );
      },
    );
  }

  Future<void> loadUsers()async{
    isload =true;
    await userDB.streamBuilder().listen((event) {
      for(var item in event){
        var check =false;
        for(var x in widget.listMemberGroup){
          if(item.id_user == x!.id_user){
            check = true;
            break;
          }
        }
        if(!check){
          ListMember.add(item);
        }
        check = false;
      }
      Listsearch = ListMember;
    },);

    setState(() {
      isload =false;
    });
  }
}
