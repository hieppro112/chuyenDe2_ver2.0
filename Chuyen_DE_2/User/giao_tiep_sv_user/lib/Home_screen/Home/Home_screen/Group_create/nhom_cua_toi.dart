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

  // ✅ Dữ liệu mẫu
  final List<Map<String, dynamic>> groups = [
    {
      "name": "Dev vui vẻ",
      "image": "assets/images/dev.png",
      "id": "DEV_VUI_VE_ID",
    },
    {
      "name": "Cơ sở dữ liệu",
      "image": "assets/images/database.png",
      "id": "CSDL_ID",
    },
    {
      "name": "Công nghệ vui vẻ",
      "image": "assets/images/database.png",
      "id": "CNVV_ID",
    },
    {
      "name": "Lập trình di động",
      "image": "assets/images/dev.png",
      "id": "LTDĐ_ID",
    },
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

  // Drawer bên trái
  Drawer _buildDrawer() {
    return Drawer(
      child: LeftPanel(
        onClose: () => Navigator.of(context).pop(),
        onGroupSelected: (id, name) {
          // Có thể thêm logic cập nhật GlobalState ở đây
        },
        isGroupPage: true,
      ),
    );
  }

  // AppBar
  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      title: const Text(
        "Nhóm của tôi",
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      iconTheme: const IconThemeData(color: Colors.black),
      actions: [
        IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 21),
          onPressed: () => Navigator.pop(context),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  // Body chính
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

  // Danh sách nhóm
  Widget _buildGroupList() {
    return ListView.builder(
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final group = groups[index];
        return _buildGroupCard(group);
      },
    );
  }

  // Card nhóm
  Widget _buildGroupCard(Map<String, dynamic> group) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
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

  // Ảnh nhóm
  Widget _buildGroupImage(String imagePath) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.asset(imagePath, width: 60, height: 60, fit: BoxFit.cover),
    );
  }

  // Thông tin nhóm + nút truy cập
  Widget _buildGroupInfo(Map<String, dynamic> group) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            group["name"],
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          _buildAccessButton(group["id"], group["name"]),
        ],
      ),
    );
  }

  // Nút truy cập
  Widget _buildAccessButton(String groupId, String groupName) {
    return OutlinedButton(
      onPressed: () => _handleAccessGroup(groupId, groupName),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Colors.blueAccent),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Truy cập", style: TextStyle(color: Colors.blueAccent)),
          SizedBox(width: 6),
          Icon(Icons.arrow_forward, color: Colors.blueAccent, size: 18),
        ],
      ),
    );
  }

  // Xử lý truy cập nhóm
  void _handleAccessGroup(String groupId, String groupName) {
    print(">>> Đang chuyển hướng và chọn nhóm: ID=$groupId | Tên=$groupName");

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Home()),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đang truy cập nhóm "$groupName" (ID: $groupId)'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
