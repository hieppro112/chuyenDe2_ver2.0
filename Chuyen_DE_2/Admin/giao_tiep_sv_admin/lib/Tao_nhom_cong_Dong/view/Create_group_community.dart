import 'dart:io';

import 'package:flutter/material.dart';
import 'package:giao_tiep_sv_admin/Data/Group.dart';
import 'package:giao_tiep_sv_admin/Data/Users.dart';
import 'package:giao_tiep_sv_admin/Data/faculty.dart';
import 'package:giao_tiep_sv_admin/FirebaseFirestore/GroupsFirebase.dart';
import 'package:giao_tiep_sv_admin/Tao_nhom_cong_Dong/view/Screen_uyquyen.dart';
import 'package:giao_tiep_sv_admin/Tao_nhom_cong_Dong/widget/custom_all_khoa.dart';
import 'package:giao_tiep_sv_admin/Tao_nhom_cong_Dong/widget/selected.dart';
import 'package:giao_tiep_sv_admin/widget/MyButton.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class ScreenCommunityGroup extends StatefulWidget {
  const ScreenCommunityGroup({super.key});

  @override
  State<ScreenCommunityGroup> createState() => _ScreenCommunityGroupState();
}

class _ScreenCommunityGroupState extends State<ScreenCommunityGroup> {
  final urlImageGroup =
      "https://i.pinimg.com/736x/28/5f/6a/285f6a1b06bc79a6e1c50c7326ba6ce9.jpg";
  final Groupsfirebase firebaseServicesGroup = Groupsfirebase();
  File? avt_group = null;
  List<String> khoa = ["CNTT", "Kế Toán", "Điện", "Ô Tô", "Cơ khí"];
  TextEditingController nameGroup = TextEditingController();
  TextEditingController descriptionGroup = TextEditingController();
  List<Users> listSelected_uyquyen = [];
  List<Faculty> listSelected_khoa = [];

  List<Users> ListMember = [
   
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff5f5f5),
      appBar: AppBar(
        backgroundColor: Color(0xfff5f5f5),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
          color: Colors.black,
          iconSize: 25,
        ),
        title: Text(
          "Tạo nhóm cộng đồng",
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            createNameGroup(),
            SizedBox(height: 10),
            createDescription(),
            SizedBox(height: 10),
            create_avt(),
            SizedBox(height: 10),
            createButton(),
            SizedBox(height: 15),
            CustomSlected(
              Throws: 1,
              listmember: listSelected_uyquyen,
              listFaculty: listSelected_khoa,
            ),
            SizedBox(height: 30),
            complate_create(),
          ],
        ),
      ),
    );
  }

  //xu ly tao nhom

  //nut xac nhan tao nhom
  Widget complate_create() {
    return InkWell(
      onTap: () {
        if (nameGroup.text.trim().isEmpty ||
            descriptionGroup.text.trim().isEmpty ||
            avt_group == null ||
            listSelected_khoa.length <= 0 ||
            listSelected_uyquyen.length <= 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Vui lòng đưa đầy đủ thông tin!'),
              duration: Duration(seconds: 3),
            ),
          );
        } else {
          // lấy id ngẫu nhiên
          final groupId = const Uuid().v4();
          final groupName = nameGroup.text;
          final groupDes = descriptionGroup.text;
          final groupMode = false;
          final groupAvt = urlImageGroup;
          final groupType = 0;
          Map<String, String> groupcreatedBy = {};
          for (var item in listSelected_uyquyen) {
            groupcreatedBy[item.id_user] = item.fullname;
          }
          Map<String, String> faculty_id_apply = {};
          for (var item in listSelected_khoa) {
            print("id item: ${item.id}");
            faculty_id_apply[item.id] = item.name_faculty;
          }
          Group group = Group(
            id: groupId,
            name: groupName,
            description: groupDes,
            created_by: groupcreatedBy,
            faculty_id: faculty_id_apply,
            approval_mode: groupMode,
            avt: groupAvt,
            type_group: groupType,
          );
          firebaseServicesGroup.createGroupAdmin(group);
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã tạo nhóm thành công !'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      },
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 25, vertical: 5),
          decoration: BoxDecoration(
            color: Color(0xff55B9F6),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.grey, width: 0.9),
          ),
          child: Text(
            "Tạo nhóm",
            style: TextStyle(fontSize: 20, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget createButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Mybutton(
          url_icon: 'assets/images/admin.png',
          nameButton: "Ủy quyền",
          Mycolor: Colors.white,
          ontap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Screen_uyquyen(
                throwss: 1,
                GetList: (value) {
                  setState(() {
                    listSelected_uyquyen = value;
                  });
                },
              ),
            ),
          ),
        ),
        Mybutton(
          url_icon: 'assets/images/group.png',
          nameButton: "Khoa",
          Mycolor: Colors.white,
          ontap: () {


            showDialog(
              context: context,
              builder: (context) => CustomAllKhoa(
                listKhoa_out: (value) {
                  setState(() {
                    listSelected_khoa = value;
                  });
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget createNameGroup() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Tên Nhóm:", style: TextStyle(fontSize: 25)),
        SizedBox(height: 5),
        TextField(
          controller: nameGroup,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.lightBlueAccent),
            ),
            //border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  //tạo phần mô tả
  Widget createDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Mô Tả:", style: TextStyle(fontSize: 25)),
        SizedBox(height: 5),
        TextField(
          textAlignVertical: TextAlignVertical.top,
          minLines: 3,
          maxLines: 5,
          controller: descriptionGroup,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.lightBlueAccent),
            ),
          ),
        ),
      ],
    );
  }

  Widget create_avt() {
    return Row(
      children: [
        Expanded(
          child: Text("Chọn ảnh đại diện:", style: TextStyle(fontSize: 20)),
        ),
        Expanded(
          child: InkWell(
            onTap: () async {
              print("pick img");
              final ImagePicker pickerImg = ImagePicker();
              final XFile? image = await pickerImg.pickImage(
                source: ImageSource.gallery,
              );
              if (image != null) {
                setState(() {
                  avt_group = File(image.path);
                });
              }
            },
            child: (avt_group == null)
                ? Image.asset(
                    'assets/images/picked_avt_group.png',
                    width: 100,

                    height: 100,
                    fit: BoxFit.contain,
                  )
                : Image.file(
                    // avt_group.path?'assets/images/picked_avt_group.png',
                    avt_group!,
                    fit: BoxFit.contain,
                    width: 45,
                    height: 45,
                  ),
          ),
        ),
      ],
    );
  }
}
