// left_panel.dart

import 'package:flutter/material.dart';
import 'Group_create/tham_gia_nhom.dart';
import 'package:giao_tiep_sv_user/Home_screen/home.dart';
import 'package:giao_tiep_sv_user/Data/global_state.dart';
import 'package:giao_tiep_sv_user/FireBase_Service/get_joined_groups.dart';

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
  final GetJoinedGroupsService _groupService = GetJoinedGroupsService();
  final TextEditingController _searchController = TextEditingController();

  // ID người dùng hiện tại (Lấy từ global state, hoặc mặc định)
  final String _currentUserId = GlobalState.currentUserId.isNotEmpty
      ? GlobalState.currentUserId
      : "23211TT4679"; // ID mặc định nếu chưa đăng nhập

  List<Map<String, dynamic>> _groups = [];
  List<Map<String, dynamic>> _filteredGroups = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchGroups();
    // Thêm listener để tự động lọc khi gõ
    _searchController.addListener(_filterGroups);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterGroups);
    _searchController.dispose();
    super.dispose();
  }

  // Hàm tải danh sách nhóm từ Firebase
  Future<void> _fetchGroups() async {
    setState(() => _isLoading = true);
    final fetched = await _groupService.fetchJoinedGroups(_currentUserId);
    setState(() {
      _groups = fetched;
      _filteredGroups = fetched;
      _isLoading = false;
      if (_searchController.text.isNotEmpty) {
        _filterGroups();
      }
    });
  }

  // Hàm lọc nhóm
  void _filterGroups() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      if (query.isEmpty) {
        _filteredGroups = _groups;
      } else {
        _filteredGroups = _groups
            .where(
              (group) => (group["name"] ?? "").toLowerCase().contains(query),
            )
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

            //  Thanh tìm kiếm
            TextField(
              controller: _searchController,
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

            //  Nút "Trang chủ"
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

            //  Danh sách nhóm có lọc
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredGroups.isEmpty
                  ? Center(
                      child: Text(
                        // Hiển thị User ID để debug: Cần đảm bảo ID này không trống
                        "Không tìm thấy nhóm. User ID: $_currentUserId",
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: _filteredGroups.length,
                      itemBuilder: (context, index) {
                        final group = _filteredGroups[index];
                        return ListTile(
                          leading: Icon(group["icon"] as IconData),
                          title: Text(group["name"]),
                          onTap: () {
                            widget.onGroupSelected(group["name"]);
                            widget.onClose();
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
