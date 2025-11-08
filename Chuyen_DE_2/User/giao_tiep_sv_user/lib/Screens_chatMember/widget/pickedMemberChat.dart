import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:giao_tiep_sv_user/Data/Users.dart';
import 'package:giao_tiep_sv_user/Data/faculty.dart';
import 'package:giao_tiep_sv_user/FireBase_Service/UserServices.dart';
import 'package:giao_tiep_sv_user/Screen_member_group/widget/customSearch.dart';
import 'package:giao_tiep_sv_user/Screens_chatMember/widget/customMemberUyquyen.dart';


class Pickedmemberchat extends StatefulWidget {
  final ValueChanged<List<Users>>? GetList;
  final int throwss;

  const Pickedmemberchat({super.key, this.GetList, required this.throwss});

  @override
  State<Pickedmemberchat> createState() => _Pickedmemberchat();
}

class _Pickedmemberchat extends State<Pickedmemberchat> {
  List<Users> listUyQuyen = [];
  bool isLoading = false;
  final firestoreService = Userservices();
  String selectedKhoa = "all";
  List<Users> listUyQuyen_out = [];
  List<Users> Listsearch = [];
  Map<String, bool> selectedMember = {};

  List<Faculty> dsKhoa = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    //load nguoi dung
    featchMembers();
    // Listsearch = listUyQuyen;

    //load cac khoa trong dialog
    featchFaculty();
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
          "Chọn người trò chuyện",
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),

      body: Container(
        child: Column(
          children: [
            Customsearch(
              onTap: (value) {
                setState(() {
                  Listsearch = listUyQuyen.where((element) {
                    return element.fullname.toLowerCase().contains(
                      value.toLowerCase(),
                    );
                  }).toList();
                });
              },
            ),
            SizedBox(height: 8),
            search(),
            SizedBox(height: 8),
            Text(
              "Danh Sách người dùng",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Expanded(child: createListmember()),
          ],
        ),
      ),
    );
  }

  Widget search() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        createChoseKhoa(),
        InkWell(
          onTap: () {
            widget.GetList?.call(listUyQuyen_out);
            Navigator.pop(context);
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Color(0xff55B9F6),
              border: Border.all(color: Colors.grey, width: 0.6),
            ),
            child: Row(
              children: [
                Text(
                  "Xong",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  //menu chon khoa
  Widget createChoseKhoa() {
    return PopupMenuButton<String>(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          border: Border.all(color: Colors.black, width: 1),
        ),
        child: Row(
          children: [
            Text(
              "Khoa: ${selectedKhoa.toString()}",
              style: TextStyle(fontSize: 14, color: Colors.black),
            ),
            Icon(Icons.arrow_drop_down_outlined, size: 30, color: Colors.black),
          ],
        ),
      ),
      onSelected: (value) {
        if (value == "all") {
          setState(() {
            selectedKhoa = value;
            Listsearch = listUyQuyen;
          });
        } else {
          setState(() {
            selectedKhoa = value;
            Listsearch = listUyQuyen.where((element) {
              return element.faculty_id.toLowerCase().contains(
                value.toLowerCase(),
              );
            }).toList();
          });
        }
        print(value);
      },
      itemBuilder: (context) {
        return dsKhoa.map((e) {
          return PopupMenuItem(value: e.faculty_id, child: Text(e.name_faculty));
        }).toList();
      },
    );
  }

  //hiển thị toàn bộ người dùng
  Widget createListmember() {
    return (isLoading == false)
        ? ListView.builder(
            shrinkWrap: true,
            //physics: NeverScrollableScrollPhysics(),
            itemCount: Listsearch.length,
            itemBuilder: (context, index) {
              var valueItem = Listsearch[index];
              bool selectMember = selectedMember[valueItem.id_user] ?? false;
              return CustommemberUyQuyen(
                selectedMember: selectMember,
                user: valueItem,
                ontap: (value) {
                  print("tap email: ${valueItem.email}");
                  setState(() {
                    selectedMember[valueItem.id_user] = value ?? false;
                    if (value == true) {
                      listUyQuyen_out.add(valueItem);
                    } else {
                      listUyQuyen_out.removeWhere((element) {
                        return element.id_user.contains(valueItem.id_user);
                      });
                    }
                  });

                  print("ds uy quyen = ${listUyQuyen_out.length}");
                },
              );
            },
          )
        : Center(child: CircularProgressIndicator());
  }

  //lấy danh sách khoa vào
  Future<void> featchFaculty() async {
    final snap = await FirebaseFirestore.instance.collection("Faculty").get();
    final data = snap.docs.map((e) {
      final map = e.data();
      return Faculty(
        faculty_id: map['id'].toString() ?? "",
        name_faculty: map['name'] ?? "",
      );
    }).toList();

    setState(() {
      dsKhoa = data;
    });
  }

  //lay dach sach nguoi dung vao list uy quyen
  Future<void> featchMembers() async {
    isLoading = true;
    // final snap = await FirebaseFirestore.instance.collection("Users").get();

    // final data = snap.docs.map((e) {
    //   final mapData = e.data();
    //   return Users(
    //     id_user: e.id,
    //     email: mapData["email"] ?? "",
    //     pass: mapData["pass"] ?? "",
    //     fullname: mapData["fullname"] ?? "",
    //     url_avt: mapData["avt"] ?? "",
    //     role: mapData["role"] ?? 0,
    //     faculty_id: mapData["faculty_id"] ?? "",
    //   );
    // }).toList();

    // setState(() {
    //   listUyQuyen = data;
    //   Listsearch =data;
    //   isLoading =false;
    // });

    try {
      // FirebaseFirestore.instance.collection("Users").snapshots().listen((
      //   event,
      // ) {
      //   final data = event.docs.map((e) {
      //     final mapData = e.data();
      //     return Users(
      //       id_user: e.id,
      //       email: mapData["email"] ?? "",
      //       pass: mapData["pass"] ?? "",
      //       fullname: mapData["fullname"] ?? "",
      //       url_avt: mapData["avt"] ?? "",
      //       role: mapData["role"] ?? 0,
      //       faculty_id: mapData["faculty_id"] ?? "",
      //     );
      //   }).toList();

      firestoreService.streamBuilder().listen((data) {
        setState(() {
          listUyQuyen = data;
          Listsearch = data;
          isLoading = false;
        });
      },);

      
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      debugPrint(" Lỗi khi load Faculty: $e");
    }
  }
}
