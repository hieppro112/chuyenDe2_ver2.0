import 'package:flutter/material.dart';
import 'Group_create/tham_gia_nhom.dart';
import 'package:giao_tiep_sv_user/Home_screen/home.dart';

class LeftPanel extends StatefulWidget {
  final VoidCallback onClose;
  final bool isGroupPage;
  final void Function(String) onGroupSelected;

  const LeftPanel({
    super.key,
    required this.onClose,
    required this.onGroupSelected,
    this.isGroupPage = false,
  });

  @override
  State<LeftPanel> createState() => _LeftPanelState();
}

class _LeftPanelState extends State<LeftPanel> {
  //  Dữ liệu nhóm gốc
  final List<Map<String, dynamic>> _groups = const [
    {"name": "Tất cả", "icon": Icons.public},
    {"name": "Mobile - (Flutter, Kotlin)", "icon": Icons.phone_android},
    {"name": "Thiết kế đồ họa", "icon": Icons.computer},
    {"name": "DEV - vui vẻ", "icon": Icons.developer_mode},
    {"name": "CNTT", "icon": Icons.school},
  ];

  //  Danh sách nhóm đang hiển thị
  late List<Map<String, dynamic>> _filteredGroups;

  //  Controller cho ô tìm kiếm
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredGroups = _groups; // mặc định hiển thị toàn bộ
  }

  //  Hàm lọc nhóm
  void _filterGroups(String query) {
    final lowerQuery = query.toLowerCase();

    setState(() {
      if (lowerQuery.isEmpty) {
        _filteredGroups = _groups;
      } else {
        _filteredGroups = _groups
            .where((group) => group["name"].toLowerCase().contains(lowerQuery))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        width: 260,
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header "Nhóm" + nút Mở rộng
            Row(
              children: [
                const Text(
                  "Nhóm:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                if (!widget.isGroupPage)
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ThamGiaNhomPage(),
                        ),
                      );
                      widget.onClose();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightGreenAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("Mở rộng", style: TextStyle(color: Colors.black)),
                        SizedBox(width: 6),
                        Icon(
                          Icons.arrow_forward,
                          color: Colors.black,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            //  Thanh tìm kiếm
            TextField(
              controller: _searchController,
              onChanged: _filterGroups,
              decoration: InputDecoration(
                hintText: "Tìm nhóm...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade200,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),

            //  Nút "Trang chủ"
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text("Trang chủ"),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const Home()),
                );
                widget.onClose();
              },
            ),
            const Divider(),

            //  Danh sách nhóm có lọc
            Expanded(
              child: _filteredGroups.isEmpty
                  ? const Center(
                      child: Text(
                        "Không tìm thấy nhóm nào",
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: _filteredGroups.length,
                      itemBuilder: (context, index) {
                        final group = _filteredGroups[index];
                        return ListTile(
                          leading: Icon(group["icon"]),
                          title: Text(group["name"]),
                          onTap: () {
                            widget.onGroupSelected(group["name"]);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
