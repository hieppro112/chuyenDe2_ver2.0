import 'package:flutter/material.dart';

class CustomMemberGroupManeger extends StatefulWidget {
  final String url;
  final String fullname;
  final ValueChanged<bool?>? ontap;
  const CustomMemberGroupManeger({
    super.key,
    required this.url,
    required this.fullname,
    this.ontap,
  });

  @override
  State<CustomMemberGroupManeger> createState() => _CustomMemberGroupManeger();
}

class _CustomMemberGroupManeger extends State<CustomMemberGroupManeger> {
  bool ischecked = false;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              //create img avatar
              ClipOval(
                child: Image.asset(
                  widget.url,
                  fit: BoxFit.fill,
                  height: 40,
                  width: 40,
                ),
              ),
              SizedBox(width: 15),
              //name
              Text(
                widget.fullname,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),

          createDialog(context),
        ],
      ),
    );
  }
}

Widget createDialog(BuildContext context) {
  return PopupMenuButton<String>(
    icon: Icon(Icons.more_horiz),
    onSelected: (value) {
      value == 'delete'?print(value):value == 'post'?print(value):value == 'upmember'?print(value):print(value);
    ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
              content: Text('Đã $value thành viên!'),
              duration: Duration(seconds: 3),
            ),
          );
    },
    itemBuilder: (context) {
      return [
        PopupMenuItem<String>(
          value: "delete",
          child: Text("Xóa thành viên", style: TextStyle(color: Colors.red)),
        ),

        PopupMenuItem<String>(
          value: "post",
          child: Text("Các bài viết của thành viên", style: TextStyle(color: Colors.black)),
        ),

        PopupMenuItem<String>(
          value: "upmember",
          child: Text("Thêm thành viên làm quản trị", style: TextStyle(color: Colors.black)),
        ),
      ];
    },
  );
}