import 'package:flutter/material.dart';
import 'package:giao_tiep_sv_user/Data/Users.dart';
import 'package:giao_tiep_sv_user/Screen_member_group/widget/customMember.dart';
import 'package:giao_tiep_sv_user/Screen_member_group/widget/customSearch.dart';

class AddMemberScreen extends StatefulWidget {
  const AddMemberScreen({super.key});

  @override
  State<AddMemberScreen> createState() => _AddMemberScreenState();
}

class _AddMemberScreenState extends State<AddMemberScreen> {
  List<Users> Listsearch = [];
  List<Users> ListMember = [
    Users(
      id_user: "23211TT3598@mail.tdc.edu.vn",
      email: "23211TT3598@mail.tdc.edu.vn",
      pass: "123456",
      fullname: "Lê Đại Hiệp",
      phone: "0898415185",
      url_avt: "assets/images/avatar.png",
      role: 0,
      faculty_id: 1,
    ),
    Users(
      id_user: "23211TT3599@mail.tdc.edu.vn",
      email: "23211TT3599@mail.tdc.edu.vn",
      pass: "123456",
      fullname: "Lê Đình Thuận",
      phone: "0898415185",
      url_avt: "assets/images/avatar.png",
      role: 0,
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
      role: 0,
      faculty_id: 1,
    ),
  ];

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
                  print(checkSearchMail);
                });
                print("length : ${Listsearch.length}");
                print("$value");
              },
            ),
            SizedBox(height: 10),
            Text(
              "Kết quả:1",
              style: TextStyle(
                color: Colors.black.withOpacity(0.6),
                fontSize: 15,
              ),
            ),
            SizedBox(height: 10),
            create_listMember(),
          ],
        ),
      ),

      //nut them xac nhan
      floatingActionButton: FloatingActionButton(
        onPressed: () async{
          ScaffoldMessenger.of(context).showSnackBar(
            await const SnackBar(
              content: Text('Đã thêm thành viên vào nhóm !'),
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

  Widget create_listMember() {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: Listsearch.length,
      itemBuilder: (context, index) {
        var value = Listsearch[index];
        return CustommemberWidget(
          id: value.id_user,
          url: value.url_avt,
          fullname: value.fullname,
        );
      },
    );
  }
}
