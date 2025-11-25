import 'package:flutter/material.dart';

class ClickedOutGroup extends StatefulWidget {
  const ClickedOutGroup({super.key});

  @override
  State<ClickedOutGroup> createState() => _ClickedOutGroupState();
}

class _ClickedOutGroupState extends State<ClickedOutGroup> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
              onTap: () {
                print("clicked roi nhom chat");
              },
              child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.red,
                ),
                child: Row(
                  children: [
                    Icon(Icons.output_rounded, color: Colors.white),
                    SizedBox(width: 10),
                    Text("Rời nhóm", style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            );
  }
}