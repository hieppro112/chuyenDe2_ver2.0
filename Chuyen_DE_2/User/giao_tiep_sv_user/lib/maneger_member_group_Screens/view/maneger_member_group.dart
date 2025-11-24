import 'package:flutter/material.dart';
import 'package:giao_tiep_sv_user/Data/Users.dart';
import 'package:giao_tiep_sv_user/FireBase_Service/UserServices.dart';
import 'package:giao_tiep_sv_user/Screen_member_group/view/Add_member.dart';
import 'package:giao_tiep_sv_user/Screen_member_group/widget/customSearch.dart';
import 'package:giao_tiep_sv_user/Widget/MyButton.dart';
import 'package:giao_tiep_sv_user/maneger_member_group_Screens/serviceGroup/groupService.dart';
import 'package:giao_tiep_sv_user/maneger_member_group_Screens/widget/custom_member_group.dart';

class ManegerMemberGroupScreen extends StatefulWidget {
  final String idGroup;
  const ManegerMemberGroupScreen({super.key, required this.idGroup});

  @override
  State<ManegerMemberGroupScreen> createState() =>
      _ManegerMemberGroupScreenState();
}

class _ManegerMemberGroupScreenState extends State<ManegerMemberGroupScreen> {
  final manegerDB = GroupserviceManeger();
  final userDB = Userservices();
  List<Users?> Listsearch = [];
  List<Users?> ListMember = [];

  bool isload = false;
  bool selecAll = true;
  List<String>? idAdminGroups;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getMemberGroup(widget.idGroup);
    getAdminGroup(widget.idGroup,true);
    Listsearch = ListMember;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Thành viên",
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

        actions: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddMemberScreen(
                      groupID: widget.idGroup,
                    ),
                  ),
                );
              },
              child: Row(
                children: [
                  Icon(Icons.add),
                  SizedBox(width: 8),
                  Text(
                    "Thêm",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //button chọn tất cả hoặc quản trị
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                //xu ly hien tat ca thanh vien
                Mybutton(
                  url_icon: "assets/icons/ic_tabAll.png",
                  nameButton: "Tất cả",
                  ontap: () {
                    setState(() {
                      selecAll = true;
                      getAdminGroup(widget.idGroup,selecAll);
                      if (selecAll == true) {
                        Listsearch = ListMember;
                      }
                    });
                  },
                  Mycolor: Color(0xffECF3E5),
                ),

                // xu ly hien thi chi quan tri vien
                Mybutton(
                  Mycolor: Color(0xffFFE5E5),
                  url_icon: "assets/icons/ic_group.png",
                  nameButton: "Quản trị",
                  ontap: () {
                    setState(() {
                      selecAll = false;
                      getAdminGroup(widget.idGroup,selecAll);
                      if (selecAll == false) {
                        Listsearch = ListMember.where((element) {
                          return idAdminGroups!.any((valueItem) {
                            return element!.id_user.toLowerCase().trim() ==
                                valueItem.toLowerCase().trim();
                          });
                        }).toList();
                      }
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 10),
            Customsearch(
              onTap: (value) {
                setState(() {
                  bool checkSearchMail = value.contains("@mail.tdc.edu.vn");
                  if (checkSearchMail == true) {
                    Listsearch = ListMember.where((element) {
                      // print("e: ${element.email}");
                      return element!.email.toLowerCase().contains(
                        value.toLowerCase(),
                      );
                    }).toList();
                  } else {
                    Listsearch = ListMember.where((element) {
                      return element!.fullname.toLowerCase().contains(
                        value.toLowerCase(),
                      );
                    }).toList();
                  }
                });
              },
            ),
            Expanded(child: createListMember()),
          ],
        ),
      ),
    );
  }

  //list cac member
  Widget createListMember() {
    return (isload)
        ? Center(child: CircularProgressIndicator(color: Colors.blueAccent))
        : ListView.builder(
            // physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: Listsearch.length,
            itemBuilder: (context, index) {
              var value = Listsearch[index];
              return CustomMemberGroupManeger(
                url: value!.url_avt,
                fullname: value!.fullname,
              );
            },
          );
  }

  //lay danh sach thanh vien trong nhom
  Future<void> getMemberGroup(String idRoom) async {
    isload = true;
    ListMember.clear();
    var listData = await manegerDB.listChat(idRoom);
    for (var item in listData) {
      var newValue = await userDB.getUserForID(item!);
      ListMember.add(newValue);
    }

    if (mounted) {
      setState(() {
        isload = false;
      });
    }
  }

  //lay danh sach admin
  Future<void> getAdminGroup(String idRoom,bool type) async {
    isload = true;
    List<String>? listTemp=[]; 
    listTemp = await manegerDB.getCreateAtID(idRoom,type);
    setState(() {
      idAdminGroups = listTemp;
      print("length: ${listTemp!.length}");
      isload = false;
    });
  }
}
