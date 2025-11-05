import 'package:flutter/material.dart';
import 'package:giao_tiep_sv_user/Home_screen/home.dart';
import '../left_panel.dart';

class NhomCuaToi extends StatefulWidget {
  const NhomCuaToi({super.key});

  @override
  State<NhomCuaToi> createState() => _NhomCuaToiState();
}

class _NhomCuaToiState extends State<NhomCuaToi> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  //  Dữ liệu mẫu
  final List<Map<String, dynamic>> groups = [
    {"name": "Dev vui vẻ", "image": "assets/images/dev.png"},
    {"name": "Cơ sở dữ liệu", "image": "assets/images/database.png"},
    {"name": "Công nghệ vui vẻ", "image": "assets/images/database.png"},
    {"name": "Lập trình di động", "image": "assets/images/dev.png"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      drawer: _buildDrawer(),
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  //  Drawer bên trái
  Drawer _buildDrawer() {
    return Drawer(
      child: LeftPanel(
        onClose: () => Navigator.of(context).pop(),
        onGroupSelected: (_) {},
        isGroupPage: true,
      ),
    );
  }

  //  AppBar
  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu, color: Colors.black),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
      ),
      title: const Text(
        "Nhóm của tôi ",
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 21),
          onPressed: () => Navigator.pop(context),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  //  Body chính
  Widget _buildBody() {
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: _buildGroupList(),
          ),
        ),
      ],
    );
  }

  //  Danh sách nhóm
  Widget _buildGroupList() {
    return ListView.builder(
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final group = groups[index];
        return _buildGroupCard(group);
      },
    );
  }

  //  Từng nhóm (card)
  Widget _buildGroupCard(Map<String, dynamic> group) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black87, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGroupImage(group["image"]),
          const SizedBox(width: 16),
          _buildGroupInfo(group),
        ],
      ),
    );
  }

  //  Ảnh nhóm
  Widget _buildGroupImage(String imagePath) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.asset(imagePath, width: 70, height: 70, fit: BoxFit.contain),
    );
  }

  // Tên nhóm + nút truy cập
  Widget _buildGroupInfo(Map<String, dynamic> group) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            group["name"],
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          _buildAccessButton(group["name"]),
        ],
      ),
    );
  }

  //
  Widget _buildAccessButton(String groupName) {
    return OutlinedButton(
      onPressed: () => _handleAccessGroup(groupName),
      style: OutlinedButton.styleFrom(
        backgroundColor: const Color(0xFFDDE9FF),
        side: const BorderSide(color: Color(0xFF1F65DE), width: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Text(
            "Truy cập",
            style: TextStyle(
              color: Color(0xFF1F65DE),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 6),
          Icon(Icons.arrow_forward, size: 18, color: Color(0xFF1F65DE)),
        ],
      ),
    );
  }

  //  Xử lý truy cập nhóm
  void _handleAccessGroup(String groupName) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Home()),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đang truy cập nhóm "$groupName"'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
