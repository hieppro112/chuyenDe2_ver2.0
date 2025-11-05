import 'package:flutter/material.dart';
import 'package:giao_tiep_sv_user/Data/Users.dart';
import 'package:giao_tiep_sv_user/Screen_member_group/view/Add_member.dart';
import 'package:giao_tiep_sv_user/Screen_member_group/widget/customSearch.dart';
import 'package:giao_tiep_sv_user/Widget/MyButton.dart';
import 'package:giao_tiep_sv_user/maneger_member_group_Screens/widget/custom_member_group.dart';

class ManegerMemberGroupScreen extends StatefulWidget {
  const ManegerMemberGroupScreen({super.key});

  @override
  State<ManegerMemberGroupScreen> createState() =>
      _ManegerMemberGroupScreenState();
}

class _ManegerMemberGroupScreenState extends State<ManegerMemberGroupScreen> {
  List<Users> Listsearch = [];
  List<Users> ListMember = [
    Users(
      id_user: "23211TT3598@mail.tdc.edu.vn",
      email: "23211TT3598@mail.tdc.edu.vn",
      pass: "123456",
      fullname: "Lê Đại Hiệp",
      phone: "0898415185",
      url_avt: "assets/images/avatar.png",
      role: 1,
      faculty_id: 1,
    ),
    Users(
      id_user: "23211TT3599@mail.tdc.edu.vn",
      email: "23211TT3599@mail.tdc.edu.vn",
      pass: "123456",
      fullname: "Lê Đình Thuận",
      phone: "0898415185",
      url_avt: "assets/images/avatar.png",
      role: 1,
      faculty_id: 1,
    ),
    Users(
      id_user: "23211TT3597@mail.tdc.edu.vn",
      email: "23211TT3597@mail.tdc.edu.vn",
      pass: "123456",
      fullname: "Cao Quang Khánh",
      phone: "0898415185",
      url_avt: "assets/images/avatar.png",
      role: 0,
      faculty_id: 1,
    ),
    Users(
      id_user: "23211TT3596@mail.tdc.edu.vn",
      email: "23211TT3596@mail.tdc.edu.vn",
      pass: "123456",
      fullname: "Phạm Thắng",
      phone: "0898415185",
      url_avt: "assets/images/avatar.png",
      role: 0,
      faculty_id: 1,
    ),
    Users(
      id_user: "23211TT3595@mail.tdc.edu.vn",
      email: "23211TT3595@mail.tdc.edu.vn",
      pass: "123456",
      fullname: "Lê Van Tủn",
      phone: "0898415185",
      url_avt: "assets/images/avatar.png",
      role: 1,
      faculty_id: 1,
    ),
  ];

  bool selecAll = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
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
                  MaterialPageRoute(builder: (context) => AddMemberScreen()),
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
                      selecAll = !selecAll;
                      if (selecAll == false) {
                        Listsearch = ListMember.where((element) {
                          return element.role == 1;
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
                  print(checkSearchMail);
                });
                print("length : ${Listsearch.length}");
                print("$value");
              },
            ),
            Expanded(child: createListMember()),
          ],
        ),
      ),
    );
  }

  Widget createListMember() {
    return ListView.builder(
      // physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: Listsearch.length,
      itemBuilder: (context, index) {
        var value = Listsearch[index];
        return CustomMemberGroupManeger(
          url: value.url_avt,
          fullname: value.fullname,
        );
      },
    );
  }
}