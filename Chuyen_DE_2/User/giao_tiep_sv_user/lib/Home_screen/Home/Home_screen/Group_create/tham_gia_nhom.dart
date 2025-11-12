import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:giao_tiep_sv_user/Home_screen/Home/Home_screen/Group_create/nhom_cua_toi.dart';
import '../left_panel.dart';
import 'tao_nhom_page.dart';
import '../../../../FireBase_Service/group_service.dart';

class ThamGiaNhomPage extends StatefulWidget {
  const ThamGiaNhomPage({super.key});

  @override
  State<ThamGiaNhomPage> createState() => _ThamGiaNhomPageState();
}

class _ThamGiaNhomPageState extends State<ThamGiaNhomPage> {
  bool _isOpen = false;
  // Khởi tạo Service
  final GroupService _groupService = GroupService();

  late Future<List<DocumentSnapshot>> _groupsFuture;

  @override
  void initState() {
    super.initState();
    // Gọi hàm từ Service để tải dữ liệu ban đầu
    _groupsFuture = _groupService.fetchGroupsToJoin();
  }

  void toggleMenu() {
    setState(() {
      _isOpen = !_isOpen;
    });
  }

  // --- HÀM GỬI YÊU CẦU THAM GIA NHÓM ---
  void _requestJoinGroup(String groupId, String groupName) async {
    try {
      // Gọi hàm từ Service để xử lý Firestore (status_id = 0)
      await _groupService.requestJoinGroup(groupId);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Đã gửi yêu cầu tham gia "$groupName". Vui lòng chờ quản trị viên duyệt.',
          ),
          duration: const Duration(seconds: 3),
        ),
      );

      // Làm mới danh sách sau khi gửi yêu cầu thành công
      // Nhóm này sẽ biến mất khỏi danh sách vì giờ đã có status_id = 0 trong Groups_members
      setState(() {
        _groupsFuture = _groupService.fetchGroupsToJoin();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gửi yêu cầu thất bại: $e'),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  // --- HÀM XÂY DỰNG ITEM NHÓM ---
  Widget _buildGroupListItem(Map<String, dynamic> group, String groupId) {
    // Lấy link ảnh từ trường 'avt'
    final String imageUrl = group['avt'] ?? "https://via.placeholder.com/60";

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Ảnh nhóm
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.group, size: 60, color: Colors.grey),
              ),
            ),
            const SizedBox(width: 16),

            // Tên nhóm và nút tham gia
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    group["name"] ?? 'Tên nhóm không xác định',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    'Khoa: ${group["faculty_id"]}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () => _requestJoinGroup(groupId, group["name"]),
                    icon: const Icon(Icons.handshake),
                    label: const Text("Tham Gia"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlueAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET BUILD CHÍNH ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Stack(
        children: [
          // 🔹 Nội dung chính
          SafeArea(
            child: Column(
              children: [
                AppBar(
                  backgroundColor: Colors.white,
                  elevation: 0.5,
                  leading: IconButton(
                    icon: const Icon(Icons.menu, color: Colors.black),
                    onPressed: toggleMenu,
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Tham Gia Nhóm",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.group, color: Colors.black),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const NhomCuaToi(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  centerTitle: true,
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.add, color: Colors.black),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TaoNhomPage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),

                // 🔹 Danh sách nhóm - Sử dụng FutureBuilder
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: FutureBuilder<List<DocumentSnapshot>>(
                      future: _groupsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (snapshot.hasError) {
                          return Center(
                            child: Text('Lỗi tải dữ liệu: ${snapshot.error}'),
                          );
                        }

                        final List<DocumentSnapshot> groups =
                            snapshot.data ?? [];

                        if (groups.isEmpty) {
                          return const Center(
                            child: Text(
                              "Không tìm thấy nhóm nào phù hợp để tham gia.",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey),
                            ),
                          );
                        }

                        // Hiển thị danh sách nhóm đã lọc
                        return ListView.builder(
                          itemCount: groups.length,
                          itemBuilder: (context, index) {
                            final groupDoc = groups[index];
                            final groupData =
                                groupDoc.data() as Map<String, dynamic>;
                            final groupId = groupDoc.id;

                            return _buildGroupListItem(groupData, groupId);
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 🔹 LeftPanel (menu trái)
          if (_isOpen)
            GestureDetector(
              onTap: toggleMenu,
              child: Container(
                color: Colors.black.withOpacity(0.3),
                child: Row(
                  children: [
                    LeftPanel(
                      onClose: toggleMenu,
                      isGroupPage: true,
                      onGroupSelected: (id, name) {
                        // Không cần xử lý chọn nhóm trên màn hình này
                      },
                    ),
                    Expanded(child: Container()),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
